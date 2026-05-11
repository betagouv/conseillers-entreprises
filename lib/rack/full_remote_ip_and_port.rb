module Rack
  module FullRemoteIpAndPort
    def self.call(env)
      ip = (env['action_dispatch.remote_ip'] || env['REMOTE_ADDR']).to_s
      port = env['HTTP_X_FORWARDED_PORT'] || begin
        env['puma.socket']&.peeraddr&.at(1)
      rescue StandardError
        nil
      end
      ip_with_port = port ? "#{ip}:#{port}" : ip

      xff = env['HTTP_X_FORWARDED_FOR'].presence
      xff ? "#{ip_with_port} X-Forwarded-For=#{xff}" : ip_with_port
    end
  end
end
