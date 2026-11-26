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
    send_ai_assistant_visit(started_at) if track_ai_assistant_visit?
  end

  def send_ai_assistant_visit(started_at)
    Matomo::AiAssistantTracker.track(
      url: request.base_url + request.path,
      user_agent: request.user_agent,
      http_status: response.status,
      bytes: response.body.bytesize,
      server_time_ms: Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond) - started_at,
      requested_at: Time.current
    )
  rescue StandardError => e
    Appsignal.send_exception(e)
  end

  def track_ai_assistant_visit?
    ENV['MATOMO_BOT_TRACKING_ENABLED'].to_b && request.get? && Matomo.ai_assistant?(request.user_agent)
  end
end
