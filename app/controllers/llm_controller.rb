class LLMController < SharedController
  include MatomoAiAssistantTracking

  def show
    content = Rails.cache.fetch('llms_txt', expires_in: 12.hours) { LLMGenerator.perform }
    render plain: content, content_type: "text/plain"
  end
end
