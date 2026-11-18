require 'rails_helper'

RSpec.describe 'Matomo AI assistant tracking' do
  let(:ai_assistant_user_agent) { 'Mozilla/5.0 (compatible; ChatGPT-User/1.0; +https://openai.com/bot)' }
  let(:browser_user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 15.0; rv:140.0) Gecko/20100101 Firefox/140.0' }
  let(:tracking_enabled) { 'true' }

  before do
    create :landing, :home
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MATOMO_BOT_TRACKING_ENABLED').and_return(tracking_enabled)
  end

  describe 'llms.txt' do
    before { allow(LLMGenerator).to receive(:perform).and_return('# Conseillers Entreprises') }

    it 'tracks an AI assistant visit' do
      get '/llms.txt', headers: { 'User-Agent' => 'Claude-User/1.0' }

      expected_visit = {
        url: 'http://www.example.com/llms.txt',
        user_agent: 'Claude-User/1.0',
        http_status: 200,
        bytes: '# Conseillers Entreprises'.bytesize
      }
      expect(MatomoAiAssistantTrackingJob).to have_been_enqueued.with(hash_including(expected_visit))
    end
  end

  describe 'public pages' do
    it 'tracks an AI assistant visit' do
      get '/', headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(response).to have_http_status(:ok)
      expected_visit = { url: 'http://www.example.com/', user_agent: ai_assistant_user_agent, http_status: 200 }
      expect(MatomoAiAssistantTrackingJob).to have_been_enqueued.with(hash_including(expected_visit))
    end

    it 'does not track a browser visit' do
      get '/', headers: { 'User-Agent' => browser_user_agent }

      expect(MatomoAiAssistantTrackingJob).not_to have_been_enqueued
    end

    it 'does not track a visit without user agent' do
      get '/', headers: { 'User-Agent' => '' }

      expect(MatomoAiAssistantTrackingJob).not_to have_been_enqueued
    end
  end

  describe 'redirections in a public controller' do
    let(:paused_landing) { create :landing, paused_at: Time.zone.now }

    it 'tracks the redirect status' do
      get "/aide-entreprise/#{paused_landing.slug}/theme/any-theme", headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(response).to have_http_status(:found)
      expect(MatomoAiAssistantTrackingJob).to have_been_enqueued.with(hash_including(http_status: 302))
    end
  end

  describe 'application pages' do
    it 'does not track an AI assistant visit' do
      get '/conseiller', headers: { 'User-Agent' => ai_assistant_user_agent }

      expect(MatomoAiAssistantTrackingJob).not_to have_been_enqueued
    end
  end
end
