require 'rails_helper'

RSpec.describe 'Matomo AI assistant tracking' do
  let(:ai_assistant_user_agent) { 'Mozilla/5.0 (compatible; ChatGPT-User/1.0; +https://openai.com/bot)' }
  let(:browser_user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 15.0; rv:140.0) Gecko/20100101 Firefox/140.0' }
  let(:tracking_enabled) { 'true' }

  before do
    create :landing, :home
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MATOMO_BOT_TRACKING_ENABLED').and_return(tracking_enabled)
    stub_const('Matomo::AiAssistantTracker::EXECUTOR', Concurrent::ImmediateExecutor.new)
    stub_request(:get, Matomo::TRACKER_URL).with(query: hash_including({}))
  end

  def matomo_hit(query = {})
    a_request(:get, Matomo::TRACKER_URL).with(query: hash_including(query))
  end

  describe 'llms.txt' do
    before { allow(LLMGenerator).to receive(:perform).and_return('# Conseillers Entreprises') }

    it 'tracks an AI assistant visit' do
      get '/llms.txt', headers: { 'User-Agent' => 'Claude-User/1.0' }

      expected_hit = {
        url: 'http://www.example.com/llms.txt',
        ua: 'Claude-User/1.0',
        http_status: '200',
        bw_bytes: '# Conseillers Entreprises'.bytesize.to_s
      }
      expect(matomo_hit(expected_hit)).to have_been_made
    end
  end

  describe 'public pages' do
    it 'tracks an AI assistant visit' do
      get '/', headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(response).to have_http_status(:ok)
      expected_hit = { url: 'http://www.example.com/', ua: ai_assistant_user_agent, http_status: '200' }
      expect(matomo_hit(expected_hit)).to have_been_made
    end

    it 'does not track a browser visit' do
      get '/', headers: { 'User-Agent' => browser_user_agent }

      expect(matomo_hit).not_to have_been_made
    end

    it 'does not track a visit without user agent' do
      get '/', headers: { 'User-Agent' => '' }

      expect(matomo_hit).not_to have_been_made
    end

    it 'still renders the page when tracking fails' do
      error = StandardError.new('boom')
      allow(Matomo::AiAssistantTracker).to receive(:track).and_raise(error)
      allow(Appsignal).to receive(:send_exception)

      get '/', headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(response).to have_http_status(:ok)
      expect(Appsignal).to have_received(:send_exception).with(error)
    end
  end

  describe 'redirections in a public controller' do
    let(:paused_landing) { create :landing, paused_at: Time.zone.now }

    it 'tracks the redirect status' do
      get "/aide-entreprise/#{paused_landing.slug}/theme/any-theme", headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(response).to have_http_status(:found)
      expect(matomo_hit(http_status: '302')).to have_been_made
    end
  end
end
