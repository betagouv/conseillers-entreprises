# Log all authentication attempts for security audit purposes.
# Email is intentionally NOT filtered here (unlike filter_parameter_logging.rb)
# because security logs require associating sessions to identities.
# Logs are protected by Scalingo's SecNumCloud PaaS guarantees.
Rails.application.config.after_initialize do
  Warden::Manager.after_authentication do |user, auth, opts|
    ip = Rack::FullRemoteIpAndPort.call(auth.env)
    Rails.logger.info("[AUTH] success scope=#{opts[:scope]} email=#{user.email} ip=#{ip}") # scope is always :user (single Devise scope)
  end

  Warden::Manager.before_failure do |env, opts|
    email = env.dig('rack.request.form_hash', 'user', 'email').to_s.downcase.strip
    ip = Rack::FullRemoteIpAndPort.call(env)
    Rails.logger.error("[AUTH] failure scope=#{opts[:scope]} reason=#{opts[:message]} email=#{email} ip=#{ip}")
  end
end
