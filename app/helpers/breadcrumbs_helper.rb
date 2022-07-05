module BreadcrumbsHelper
  # Breadcrumbs for landing page un new solicitations
  # ex: Landing : "Déposer une demande › Surmonter des difficultés financières "
  # ex new solicitation : "Déposer une demande › Surmonter des difficultés financières › Faire un point sur votre situation"
  def breadcrumbs_landing(landing, landing_theme, landing_subject = nil, params = {})
    html = content_tag('li', home_link(landing, params))
    if landing_subject.present?
      html << content_tag('li', link_to(landing_theme.title, landing_theme_path(landing, landing_theme, params), class: 'fr-breadcrumb__link blue'))
      html << content_tag('li', link_to(landing_subject.title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    else
      html << content_tag('li', link_to(landing_theme.title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    end
    html
  end

  # Use for "Mentions d'information" inside iframe
  def breadcrumbs_iframe_home(landing, title)
    content_tag('li', home_link(landing, params))
  end

  # Breadcrumbs used for other pages
  # Ex : "Déposer une demande › Comment ça marche ?"
  def breadcrumbs_page(title)
    html = content_tag('li', link_to(t('breadcrumbs_helper.home_link.home'), root_path, class: 'fr-breadcrumb__link blue'))
    html << content_tag('li', link_to(title, '#', class: 'fr-breadcrumb__link', 'aria-current': 'page'))
    html
  end

  private

  def home_link(landing, params = {})
    if landing.iframe? && landing.integral_iframe?
      link_to(t('breadcrumbs_helper.home_link.pde'), landing, class: 'fr-breadcrumb__link blue')
    elsif landing.iframe?
      ''
    else
      params = params.permit(:landing_slug, :pk_campaign, :pk_kwd) if params.present?
      link_to(t('breadcrumbs_helper.home_link.home'), root_path(params), class: 'fr-breadcrumb__link blue')
    end
  end
end
