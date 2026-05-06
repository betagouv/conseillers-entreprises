# Log all authentication attempts for security audit purposes.
# Email is intentionally NOT filtered here (unlike filter_parameter_logging.rb)
# because security logs require associating sessions to identities.
# Logs are protected by Scalingo's SecNumCloud PaaS guarantees.
Rails.application.config.after_initialize do
  Warden::Manager.after_authentication do |user, auth, opts|
    ip = auth.env['action_dispatch.remote_ip'] || auth.env['REMOTE_ADDR']
    Rails.logger.info("[AUTH] success scope=#{opts[:scope]} email=#{user.email} ip=#{ip}")
  end

  Warden::Manager.before_failure do |env, opts|
    email = ActionDispatch::Request.new(env).params.dig('user', 'email').to_s.downcase.strip
    ip = env['action_dispatch.remote_ip'] || env['REMOTE_ADDR']
    log_line = "[AUTH] failure scope=#{opts[:scope]} reason=#{opts[:message]} email=#{email} ip=#{ip}"

    if opts[:message] == :locked
      Rails.logger.error(log_line)
    else
      Rails.logger.warn(log_line)
    end
  end
end