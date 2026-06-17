class LLMController < SharedController
  def show
    render plain: LLMGenerator.perform, content_type: "text/plain"
  end
end
