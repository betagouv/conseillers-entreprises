# frozen_string_literal: true

# Rack::Timeout pour détecter les timeouts avant Scalingo (30s)
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= '28'

Rack::Timeout.register_state_change_observer(:appsignal_context) do |env|
  info = env['rack-timeout.info']

  if defined?(Appsignal) && info&.state == :timed_out
    Appsignal.set_tags(
      timeout: true,
      timeout_type: 'rack_timeout',
      service_time_ms: info.service
    )
  end
end

if Rails.env.development? && !ENV['DEVELOPMENT_ENABLE_RACK_ATTACK'].to_b
  Rails.application.config.middleware.delete(Rack::Timeout)
end
