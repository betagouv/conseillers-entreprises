# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# https://developers.google.com/tag-manager/web/csp Pour les CSP Google
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.font_src    :self, :data, 'https://fonts.gstatic.com'
    policy.img_src     :self, :data, 'https://jedonnemonavis.numerique.gouv.fr', 'https://stats.beta.gouv.fr/', 'https://www.google.com', 'https://www.google.fr', 'https://googleads.g.doubleclick.net', 'https://www.googletagmanager.com', 'https://www.googleadservices.com', 'https://www.gstatic.com', 'https://adservice.google.com', '415474841.privacysandbox.googleadservices.com'
    policy.object_src  :none
    policy.style_src   :self, :unsafe_inline, 'https://fonts.googleapis.com'
    policy.script_src  :self, :blob, 'https://stats.beta.gouv.fr/', 'https://cdn.jsdelivr.net/', 'https://www.googletagmanager.com/', 'https://www.googleadservices.com', 'https://googleads.g.doubleclick.net', 'https://www.google.com'
    policy.frame_src :self, 'stats.data.gouv.fr', 'stats.beta.gouv.fr', 'https://cdn.jsdelivr.net/', 'https://bid.g.doubleclick.net', 'https://tpc.googlesyndication.com', 'https://www.youtube-nocookie.com'
    policy.connect_src :self, 'https://api-adresse.data.gouv.fr/', '*.google.com', 'https://adservice.google.com', 'https://pagead2.googlesyndication.com', 'https://tpc.googlesyndication.com', 'https://googleads.g.doubleclick.net', 'https://stats.beta.gouv.fr/', 'https://www.googletagmanager.com', 'https://cdn.jsdelivr.net/'
    # Specify URI for violation reports
    if ENV["CSP_REPORT_URI"].present? && ENV["CSP_REPORT_ACTIVATED"] == "true"
      policy.report_uri ENV["CSP_REPORT_URI"]
    end
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = -> (request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
