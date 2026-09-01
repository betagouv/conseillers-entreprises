module HomeEmphasisHelper
  def path_to_emphasis_item(item, **query_params)
    case item
    when Landing
      landing_path(item, **query_params)
    when LandingSubject
      new_solicitation_path(landing_slug: "accueil", landing_subject_slug: item.slug, anchor: 'section-breadcrumbs', **query_params)
    end
  end
end
