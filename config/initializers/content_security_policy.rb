# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |p|
  p.default_src :self
  p.font_src    :self, :data, 'fonts.gstatic.com'
  p.img_src     :self, :data, 'voxusagers.numerique.gouv.fr', 'stats.data.gouv.fr'
  p.object_src  :none
  p.style_src   :self, :unsafe_inline, 'fonts.googleapis.com'
  p.script_src :self, :unsafe_eval, 'browser.sentry-cdn.com', 'sentry.io', 'stats.data.gouv.fr', 'cdn.jsdelivr.net'

  if Rails.env.development?
    p.connect_src :self, 'localhost:3035', 'ws://localhost:3035'
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
