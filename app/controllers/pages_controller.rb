class PagesController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'pages' layout
  include GeocoderIp
  include Pundit::Authorization

  before_action :setup_cookie_text
  before_action :fetch_themes

  ## Configuration for honeypot-captcha
  #
  def honeypot_fields
    { :commentaire => t('honeypot_captcha.comment') }
  end

  private

  def setup_cookie_text
    @cookie_text = t('pages.cookie_text')
  end

  def fetch_themes
    p "fetch_themes"
    @footer_landing = Landing.accueil
    @footer_landing_themes = Rails.cache.fetch('footer_landing_themes', expires_in: 1.hour) do
      @footer_landing.landing_themes.not_archived.order(:position)
    end
  end

end
