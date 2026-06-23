class LLMController < SharedController
  def show
    content = Rails.cache.fetch('llms_txt', expires_in: 1.hour) { LLMGenerator.perform }
    render plain: content, content_type: "text/plain"
  end
end
