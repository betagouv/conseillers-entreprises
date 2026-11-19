module Matomo
  BASE_HOST = 'stats.beta.gouv.fr'
  TRACKER_URL = "https://#{BASE_HOST}/matomo.php"
  SITE_ID = 74

  # Same list as Matomo's own detector (plugins/BotTracking/BotDetector.php):
  # Matomo discards any other bot request.
  AI_ASSISTANT_PATTERNS = %w[
    ChatGPT-User
    MistralAI-User
    Gemini-Deep-Research
    Claude-User
    Perplexity-User
    Google-GeminiNotebook
    Google-NotebookLM
  ].freeze

  AI_ASSISTANT_REGEXP = Regexp.new(Regexp.union(AI_ASSISTANT_PATTERNS).source, Regexp::IGNORECASE)

  def self.ai_assistant?(user_agent)
    user_agent.to_s.match?(AI_ASSISTANT_REGEXP)
  end
end
