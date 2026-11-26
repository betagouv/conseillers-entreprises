require 'rails_helper'

describe Matomo do
  describe '.ai_assistant?' do
    subject { described_class.ai_assistant?(user_agent) }

    context 'with an AI assistant user agent' do
      let(:user_agent) { 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; ChatGPT-User/1.0; +https://openai.com/bot)' }

      it { is_expected.to be true }
    end

    context 'with a lowercase AI assistant user agent' do
      let(:user_agent) { 'perplexity-user/1.0' }

      it { is_expected.to be true }
    end

    context 'with an AI crawler user agent' do
      let(:user_agent) { 'Mozilla/5.0 (compatible; GPTBot/1.1; +https://openai.com/gptbot)' }

      it { is_expected.to be false }
    end

    context 'with a search engine crawler user agent' do
      let(:user_agent) { 'Googlebot/2.1 (+http://www.google.com/bot.html)' }

      it { is_expected.to be false }
    end

    context 'without user agent' do
      let(:user_agent) { nil }

      it { is_expected.to be false }
    end

    context 'with an empty user agent' do
      let(:user_agent) { '' }

      it { is_expected.to be false }
    end
  end
end
