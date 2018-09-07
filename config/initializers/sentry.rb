Raven.configure do |config|
  # SENTRY_DSN is used to set the DSN https://docs.sentry.io/clients/ruby/
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.silence_ready = true
end
