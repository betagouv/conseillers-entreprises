# Monkey-patching for LetterOpenerWeb Content-security policy.
# This is needed because:
# - LetterOpenerWeb inlines its own style
# - The HTML emails have inline style
# See also https://github.com/fgrehm/letter_opener_web/pull/143 (which only addresse the first issue.)

module Extensions::CSP::LetterOpener
  extend ActiveSupport::Concern

  prepended do
    content_security_policy do |policy|
      policy.style_src :self, :unsafe_inline
    end

    before_action do
      request.content_security_policy_nonce_directives = %w(script-src)
    end
  end
end
