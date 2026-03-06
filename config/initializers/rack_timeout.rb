# frozen_string_literal: true

# Rack::Timeout pour détecter les timeouts avant Scalingo (30s)
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= '28'

if Rails.env.production?
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
end
