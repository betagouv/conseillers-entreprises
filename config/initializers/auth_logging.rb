# Log all authentication attempts for security audit purposes.
# Email is intentionally NOT filtered here (unlike filter_parameter_logging.rb)
# because security logs require associating sessions to identities.
# Logs are protected by Scalingo's SecNumCloud PaaS guarantees.
Rails.application.config.after_initialize do
  def self.auth_ip_with_port(env)
    ip = (env['action_dispatch.remote_ip'] || env['REMOTE_ADDR']).to_s
    port = env['HTTP_X_FORWARDED_PORT'] || begin
      env['puma.socket']&.peeraddr&.at(1)
    rescue StandardError
      nil
    end
    port ? "#{ip}:#{port}" : ip
  end

  def self.auth_forwarded_for(env)
    env['HTTP_X_FORWARDED_FOR'].presence
  end

  Warden::Manager.after_authentication do |user, auth, opts|
    ip = auth_ip_with_port(auth.env)
    xff = auth_forwarded_for(auth.env)
    extras = xff ? " X-Forwarded-For=#{xff}" : ''
    Rails.logger.info("[AUTH] success scope=#{opts[:scope]} email=#{user.email} ip=#{ip}#{extras}")
  end

  Warden::Manager.before_failure do |env, opts|
    email = ActionDispatch::Request.new(env).params.dig('user', 'email').to_s.downcase.strip
    ip = auth_ip_with_port(env)
    xff = auth_forwarded_for(env)
    extras = xff ? " X-Forwarded-For=#{xff}" : ''
    log_line = "[AUTH] failure scope=#{opts[:scope]} reason=#{opts[:message]} email=#{email} ip=#{ip}#{extras}"

    if opts[:message] == :locked
      Rails.logger.error(log_line)
    else
      Rails.logger.warn(log_line)
    end
  end
end
