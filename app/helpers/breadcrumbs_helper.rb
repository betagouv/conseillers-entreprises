module BreadcrumbsHelper
  # Breadcrumbs for landing page un new solicitations
  # For new solicitation page we need landing_option to display the form title
  # ex: Landing : "Déposer une demande › Surmonter des difficultés financières "
  # ex new solicitation : "Déposer une demande › Surmonter des difficultés financières › Faire un point sur votre situation"
  def breadcrumbs_landing(landing, landing_option = nil, params = {})
    html = home_link(params)
    if landing_option.present?
      html << link_to(landing.title, landing_path(params))
      html << arrow
      html << landing_option.form_title
    else
      html << landing.title
    end
    html
  end

  # Breadcrumbs used for other pages
  # Ex : "Déposer une demande › Comment ça marche ?"
  def breadcrumbs_page(title)
    html = home_link
    html << title
  end

  private

  def home_link(params = {})
    html = link_to t('breadcrumbs_helper.home_link.home'), root_path(params)
    html << arrow
  end

  def arrow
    tag.span('›', class: 'arrow')
  end
end
