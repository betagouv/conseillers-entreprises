class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env['action_dispatch.remote_ip'] || ip).to_s
    end
  end
  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets', '/packs')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/mon_compte/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/mon_compte/sign_in' && req.post?
      # Normalize the email, using the same logic as your authentication process, to
      # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
      req.params['user']['email'].to_s.downcase.gsub(/\s+/, "").presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end


  # Safelist pour localhost
  Rack::Attack.safelist 'allow from localhost' do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Safelist pour les plages d'IPs autorisées
  Rack::Attack.safelist 'allow from whitelisted IP ranges' do |req|
    wf_ip_ranges = ENV['WAF_IPS'].to_s.split(',').map(&:strip)
    team_ips = ENV['TEAM_IPS'].to_s.split(',').map(&:strip)

    client_ip = req.ip

    next true if team_ips.include?(client_ip)

    # Vérifier les plages d'IPs
    wf_ip_ranges.any? do |ip_range|
      begin
        IPAddr.new(ip_range).include?(client_ip)
      rescue IPAddr::InvalidAddressError
        false
      end
    end
  end

  # Bloquer toutes les autres IPs (tout ce qui n'est pas explicitement autorisé)
  Rack::Attack.blocklist('block all other IPs') do |req|
    true # Bloquer par défaut, les safelists ont priorité
  end

  Rack::Attack.blocklisted_responder = lambda do |request|
    # Using 503 because it may make attacker think that they have successfully
    # DOSed the site. Rack::Attack returns 403 for blocklists by default
    Sentry.capture_message("IP bloquée : IP = #{request.ip} ; Remote IP = #{request.remote_ip}")
    [ 403, {}, ['Forbidden']]
  end

  Rack::Attack.enabled = true
end
