module BreadcrumbsHelper
  # Breadcrumbs for landing page un new solicitations
  # ex: Landing : "Déposer une demande › Surmonter des difficultés financières "
  # ex new solicitation : "Déposer une demande › Surmonter des difficultés financières › Faire un point sur votre situation"
  def breadcrumbs_landing(landing_params = {}, query_params = {}, title = nil)
    landing = landing_params[:landing]
    landing_theme = landing_params[:landing_theme]
    landing_subject = landing_params[:landing_subject]
    html = content_tag('li', home_link(landing, query_params))
    if landing_subject.present?
      html << content_tag('li', link_to(landing_theme.title, landing_theme_path(landing, landing_theme, query_params), class: 'fr-breadcrumb__link blue')) if show_landing_theme_breadcrumb?(landing)
      html << content_tag('li', link_to(landing_subject.title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    elsif landing_theme.present?
      html << content_tag('li', link_to(landing_theme.title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    elsif title.present?
      html << content_tag('li', link_to(title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    end
    html
  end

  # Breadcrumbs used for other pages
  # Ex : "Déposer une demande › Comment ça marche ?"
  def breadcrumbs_page(title)
    html = content_tag('li', link_to(t('breadcrumbs_helper.home_link.home'), root_path, class: 'fr-breadcrumb__link blue'))
    html << content_tag('li', link_to(title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    html
  end

  private

  def show_landing_theme_breadcrumb?(landing)
    !landing.iframe? || (landing.integral_iframe? || landing.themes_iframe?)
  end

  def home_link(landing, params = {})
    if landing&.iframe?
      link_to(t('breadcrumbs_helper.home_link.iframe'), landing_path(landing, params), class: 'fr-breadcrumb__link blue')
    else
      link_to(t('breadcrumbs_helper.home_link.home'), root_path(params), class: 'fr-breadcrumb__link blue')
    end
  end
end
