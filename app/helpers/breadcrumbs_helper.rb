module BreadcrumbsHelper
  # Breadcrumbs for landing page un new solicitations
  # ex: Landing : "Déposer une demande › Surmonter des difficultés financières "
  # ex new solicitation : "Déposer une demande › Surmonter des difficultés financières › Faire un point sur votre situation"
  def breadcrumbs_landing(landing, landing_theme, landing_subject = nil, params = {})
    html = home_link(landing, params)
    if landing_subject.present?
      html << link_to(landing_theme.title, landing_theme_path(landing_theme.slug, params))
      html << arrow
      html << landing_subject.title
    else
      html << landing_theme.title
    end
    html
  end

  # Breadcrumbs used for other pages
  # Ex : "Déposer une demande › Comment ça marche ?"
  def breadcrumbs_page(title)
    html = link_to t('breadcrumbs_helper.home_link.home'), root_path(params.except(:controller, :action).presence)
    html << arrow
    html << title
  end

  private

  def home_link(landing, params = {})
    if landing.slug == 'home'
      html = link_to t('breadcrumbs_helper.home_link.home'), root_path(params)
    else
      html = link_to t('breadcrumbs_helper.home_link.home'), landing
    end
    html << arrow
  end

  def arrow
    tag.span('›', class: 'arrow')
  end
end
