class PagesController < SharedController
  # Abstract Controller for the public pages
  # implicitly uses the 'pages' layout

  before_action :setup_cookie_text
  before_action :fetch_themes

  private

  def setup_cookie_text
    @cookie_text = t('pages.cookie_text')
  end
end
