class MatomoAiAssistantTrackingJob < ApplicationJob
  HTTP_TIMEOUT_SECONDS = 5

  queue_as :low_priority

  discard_on HTTP::Error, OpenSSL::SSL::SSLError do |_job, error|
    Rails.logger.warn("Matomo AI assistant tracking failed: #{error.message}")
  end

  def perform(url:, user_agent:, http_status:, bytes:, server_time_ms:, requested_at:)
    HTTP.timeout(HTTP_TIMEOUT_SECONDS).get(Matomo::TRACKER_URL, params: {
      idsite: Matomo::SITE_ID,
      rec: 1,
      recMode: 1,
      ua: user_agent,
      url: url,
      http_status: http_status,
      bw_bytes: bytes,
      pf_srv: server_time_ms,
      cdt: Time.iso8601(requested_at).utc.strftime('%Y-%m-%d %H:%M:%S')
    })
  end
end
