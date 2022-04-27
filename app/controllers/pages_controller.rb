class PagesController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'pages' layout
  include GeocoderIp
  include Pundit::Authorization

  before_action :setup_cookie_text

  ## Configuration for honeypot-captcha
  #
  def honeypot_fields
    { :commentaire => t('honeypot_captcha.comment') }
  end

  private

  def setup_cookie_text
    @cookie_text = t('pages.cookie_text')
  end
end
