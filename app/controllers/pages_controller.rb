class PagesController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'pages' layout
  include GeocoderIp
  include Pundit

  ## Configuration for honeypot-captcha
  #
  def honeypot_fields
    { :commentaire => t('honeypot_captcha.comment') }
  end
end
