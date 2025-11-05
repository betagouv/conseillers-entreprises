require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Rails.application.routes.default_url_options = { host: ENV['HOST_NAME'] }

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = {
    'Cache-Control' => 'public, s-maxage=31536000, max-age=15552000',
    'Pragma' => 'no-cache',
    'X-Content-Type-Options' => 'nosniff'
  }

  # Recommendation of https://www.zaproxy.org/docs/alerts/10015/
  # MaJ par les defaults de Rails 7
  config.action_dispatch.default_headers = {
    'Cache-Control' => 'no-cache, no-store, must-revalidate',
    'Expires' => '0',
    'Pragma' => 'no-cache',
    'X-Content-Type-Options' => 'nosniff',
    'X-Download-Options' => "noopen",
    'X-Frame-Options' => 'SAMEORIGIN',
    'X-Permitted-Cross-Domain-Policies' => 'none',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains; preload',
    'X-XSS-Protection' => '0',
    'Referrer-Policy' => "strict-origin-when-cross-origin"
  }

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false
  config.ssl_options = { hsts: { subdomains: true, preload: false } }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :ovh

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Trust WAF Ubika/OVH proxies to read real client IP from X-Forwarded-For header
  # This is required for accurate logging and analytics (shows real client IPs instead of proxy IPs)
  # See: https://api.rubyonrails.org/classes/ActionDispatch/RemoteIp.html
  if ENV['WAF_PROXY_IPS'].present?
    config.action_dispatch.trusted_proxies = ENV['WAF_PROXY_IPS']
      .split(',')
      .map(&:strip)
      .map { |ip| IPAddr.new(ip) }
  end

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT) # rubocop:disable Style/GlobalStdStream
    .tap  { |logger| logger.formatter = Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  config.cache_store =
    :redis_cache_store, { url: ENV['REDIS_URL'], reconnect_attempts: 3,
                                                 error_handler: -> (method:, returning:, exception:) {
                                                   Sentry.capture_exception exception, level: 'warning',
                                                                           tags: { method: method, returning: returning }
                                                 }
      }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "place_des_entreprises_production"

  config.action_mailer.asset_host = ENV['HOST_NAME']
  # Actually send emails, but use sendinblue/brevo in production and Mailtrap in staging
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  if ENV['SENDINBLUE_API_KEY'].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: ENV['SENDINBLUE_USER_NAME'],
      password: ENV['SENDINBLUE_SMTP_KEY'],
      address: 'smtp-relay.brevo.com',
      port: '587',
      authentication: 'cram_md5'
    }
  elsif ENV['MAILTRAP_USER_NAME'].present? && ENV['FEATURE_SEND_STAGING_EMAILS'].to_b
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: ENV['MAILTRAP_USER_NAME'],
      password: ENV['MAILTRAP_PASSWORD'],
      address: 'smtp.mailtrap.io',
      domain: 'smtp.mailtrap.io',
      port: '2525',
      authentication: :cram_md5
    }
  else
    config.action_mailer.perform_deliveries = false
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  #
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  if ENV['STAGING_ENV'].present? && ENV['STAGING_ENV'] == 'true'
    # Let Faker load its :en text
    config.i18n.enforce_available_locales = false
  end
end
