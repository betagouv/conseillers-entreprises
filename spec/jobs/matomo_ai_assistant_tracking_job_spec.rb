require 'rails_helper'

describe MatomoAiAssistantTrackingJob do
  let(:visit_params) do
    {
      url: 'https://example.com/llms.txt',
      user_agent: 'Claude-User/1.0',
      http_status: 200,
      bytes: 1234,
      server_time_ms: 42,
      requested_at: '2026-11-18T14:00:00Z'
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

  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1, queue: 'low_priority') { described_class.perform_later(**visit_params) } }
  end

  describe '#perform' do
    it 'sends the bot hit to Matomo' do
      matomo_request = stub_request(:get, Matomo::TRACKER_URL).with(query: expected_query)

      described_class.perform_now(**visit_params)

      expect(matomo_request).to have_been_requested
    end
  end
end
