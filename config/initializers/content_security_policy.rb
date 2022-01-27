# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# https://developers.google.com/tag-manager/web/csp Pour les CSP Google
Rails.application.config.content_security_policy do |p|
  p.default_src :self
  p.base_uri    :self
  p.font_src    :self, :data, 'https://github.com', 'https://fonts.gstatic.com'
  p.img_src     :self, :data, 'https://voxusagers.numerique.gouv.fr', 'https://stats.data.gouv.fr', 'https://www.google.com', 'https://www.google.fr', 'https://googleads.g.doubleclick.net', 'https://www.googletagmanager.com', 'https://www.googleadservices.com', 'https://www.gstatic.com', 'https://adservice.google.com', '415474841.privacysandbox.googleadservices.com', 'https://www.facebook.com', 'connect.facebook.net'
  p.object_src  :none
  p.style_src   :self, :unsafe_inline, 'https://www.ssa.gov', 'https://fonts.googleapis.com'
  p.script_src  :self, :blob, :strict_dynamic, 'https://browser.sentry-cdn.com', 'sentry.io', 'https://stats.data.gouv.fr', 'https://cdn.jsdelivr.net', 'https://www.ssa.gov', 'https://www.googletagmanager.com', 'https://www.googleadservices.com', 'https://googleads.g.doubleclick.net', 'https://www.google.com', 'https://connect.facebook.net', 'https://browser.sentry-cdn.com/6.2.3/bundle.min.js'
  p.script_src_elem :self, 'https://browser.sentry-cdn.com', 'sentry.io', 'https://stats.data.gouv.fr', 'https://stats.data.gouv.fr/piwik.js', 'https://cdn.jsdelivr.net', 'www.pagespeed-mod.com', 'https://www.googletagmanager.com', 'https://www.googleadservices.com', 'https://googleads.g.doubleclick.net', 'https://www.google.com', 'https://connect.facebook.net'
  p.frame_src :self, 'stats.data.gouv.fr', 'browser.sentry-cdn.com', 'cdn.jsdelivr.net', 'https://bid.g.doubleclick.net', 'https://tube.nocturlab.fr', 'https://www.facebook.com', 'https://tpc.googlesyndication.com'
  if Rails.env.development?
    p.connect_src :self, 'localhost:3035', 'ws://localhost:3035', 'https://api-adresse.data.gouv.fr/'
  else
    p.connect_src :self, '*.sentry.io', 'https://api-adresse.data.gouv.fr/', '*.google.com', 'https://adservice.google.com', 'https://pagead2.googlesyndication.com', 'https://tpc.googlesyndication.com', 'https://googleads.g.doubleclick.net', 'https://stats.data.gouv.fr', 'https://www.facebook.com'
    if ENV["CSP_REPORT_URI"].present?
      p.report_uri ENV["CSP_REPORT_URI"]
    end
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w(script-src script-src-elem)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
