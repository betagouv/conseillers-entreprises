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

  Rack::Attack.blocklist('block bad email') do |req|
    ips = [
      '137.117.65.40', '20.168.217.16', '172.174.64.146', '13.84.52.121', '20.245.167.249', '138.91.175.192',
      '172.177.6.16', '40.86.18.81', '172.177.106.80', '172.177.114.128', '20.171.70.64', '172.177.150.114',
      '4.154.90.103', '20.42.13.24', '13.73.50.80', '13.86.66.33', '40.86.18.89', '20.185.158.17', '70.37.166.251',
      '138.91.175.198', '20.44.102.46', '20.42.15.91', '13.88.3.235'
    ]
    remote_ips = [
      '172.174.64.0', '13.84.52.0', '20.225.181.0', '20.225.181.119', '20.245.167.0', '138.91.175.0',
      '172.177.6.0', '40.86.18.0', '172.177.106.0', '172.177.114.0', '20.171.70.0', '172.177.150.0', '4.154.90.0',
      '20.42.13.0', '13.73.50.0', '13.86.66.0', '40.86.18.0', '20.185.158.0', '70.37.166.0', '138.91.175.0',
      '20.44.102.0', '20.42.15.0', '13.88.3.0'
    ]
    (req.post? && req.params['solicitation'].present? && req.params['solicitation']['email'] == 'foo-bar@example.com') ||
    ips.include?(req.ip) || remote_ips.include?(req.remote_ip)
  end

  Rack::Attack.blocklisted_responder = lambda do |request|
    # Using 503 because it may make attacker think that they have successfully
    # DOSed the site. Rack::Attack returns 403 for blocklists by default
    Sentry.capture_message("foo-bar@example.com : IP = #{request.ip} ; Remote IP = #{request.remote_ip}")
    [ 503, {}, ['Blocked']]
  end
end
