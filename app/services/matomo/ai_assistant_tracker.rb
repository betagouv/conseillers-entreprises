# Sends AI assistant visits to the Matomo Tracking API
module Matomo
  class AiAssistantTracker
    HTTP_TIMEOUT_SECONDS = 5

    EXECUTOR = Concurrent::ThreadPoolExecutor.new(
      min_threads: 0,
      max_threads: 2,
      max_queue: 100,
      fallback_policy: :discard
    )

    def self.track(url:, user_agent:, http_status:, bytes:, server_time_ms:, requested_at:)
      params = {
        idsite: Matomo::SITE_ID,
        rec: 1,
        recMode: 1,
        ua: user_agent,
        url: url,
        http_status: http_status,
        bw_bytes: bytes,
        pf_srv: server_time_ms,
        cdt: requested_at.utc.strftime('%Y-%m-%d %H:%M:%S')
      }
      EXECUTOR.post { Rails.application.executor.wrap { send_hit(params) } }
    end

    def self.send_hit(params)
      HTTP.timeout(HTTP_TIMEOUT_SECONDS).get(Matomo::TRACKER_URL, params: params)
    rescue HTTP::Error, OpenSSL::SSL::SSLError => e
      Rails.logger.warn("Matomo AI assistant tracking failed: #{e.message}")
    rescue StandardError => e
      Appsignal.send_exception(e)
    end
    private_class_method :send_hit
  end
end
