require 'rails_helper'

describe Matomo::AiAssistantTracker do
  let(:visit) do
    {
      url: 'https://example.com/llms.txt',
      user_agent: 'Claude-User/1.0',
      http_status: 200,
      bytes: 1234,
      server_time_ms: 42,
      requested_at: Time.utc(2026, 11, 18, 14)
    }
  end
  let(:expected_query) do
    {
      idsite: '74', rec: '1', recMode: '1',
      ua: 'Claude-User/1.0', url: 'https://example.com/llms.txt',
      http_status: '200', bw_bytes: '1234', pf_srv: '42',
      cdt: '2026-11-18 14:00:00'
    }
  end

  describe 'EXECUTOR' do
    it 'is bounded and drops hits beyond its capacity' do
      executor = described_class::EXECUTOR

      expect(executor.max_length).to eq 2
      expect(executor.max_queue).to eq 100
      expect(executor.fallback_policy).to eq :discard
    end
  end

  describe '.track' do
    before { stub_const('Matomo::AiAssistantTracker::EXECUTOR', Concurrent::ImmediateExecutor.new) }

    it 'sends the bot hit to Matomo' do
      matomo_request = stub_request(:get, Matomo::TRACKER_URL).with(query: expected_query)

      described_class.track(**visit)

      expect(matomo_request).to have_been_requested
    end

    it 'logs a network failure without raising' do
      stub_request(:get, Matomo::TRACKER_URL).with(query: expected_query).to_timeout
      allow(Rails.logger).to receive(:warn)

      expect { described_class.track(**visit) }.not_to raise_error
      expect(Rails.logger).to have_received(:warn).with(/Matomo AI assistant tracking failed/)
    end

    it 'reports an unexpected error, which the thread pool would otherwise swallow' do
      error = StandardError.new('boom')
      allow(HTTP).to receive(:timeout).and_raise(error)
      allow(Appsignal).to receive(:send_exception)

      described_class.track(**visit)

      expect(Appsignal).to have_received(:send_exception).with(error)
    end
  end
end
