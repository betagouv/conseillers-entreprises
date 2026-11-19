# AI assistants fetch pages server-side and never run the Matomo JS tag:
# their visits are sent to the Matomo Tracking API in bot mode instead.
module MatomoAiAssistantTracking
  extend ActiveSupport::Concern

  included do
    around_action :track_ai_assistant_visit
  end

  private

  def track_ai_assistant_visit
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
    yield
    return unless track_ai_assistant_visit?

    enqueue_ai_assistant_visit(Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond) - started_at)
  end

  def track_ai_assistant_visit?
    ENV['MATOMO_BOT_TRACKING_ENABLED'].to_b && request.get? && Matomo.ai_assistant?(request.user_agent)
  end

  def enqueue_ai_assistant_visit(server_time_ms)
    MatomoAiAssistantTrackingJob.perform_later(
      url: request.base_url + request.path,
      user_agent: request.user_agent,
      http_status: response.status,
      bytes: response.body.bytesize,
      server_time_ms: server_time_ms,
      requested_at: Time.current.utc.iso8601
    )
  rescue StandardError => e
    Rails.logger.warn("Matomo AI assistant visit not enqueued: #{e.message}")
    Appsignal.send_exception(e)
  end
end
