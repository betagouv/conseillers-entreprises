module LandingsSeoHelper
  # Helpers pour simplifier la configuration des schémas SEO dans les vues de landings

  def setup_home_seo_schemas(landing_themes:, landing:)
    title = t('landings.landings.home.meta.title')
    description = t('landings.landings.home.meta.description')

    meta(title: title, description: description)
    add_page_schema(page_schema(title: title, description: description))
    add_page_schema(item_list_schema(
                      name: t('landings.landings.seo.support_themes'),
                      description: t('landings.landings.seo.free_support_services'),
                      items: prepare_themes_schema_items(landing_themes, landing.slug)
                    ))
  end

  def setup_landing_theme_seo_schemas(landing_theme:, landing_subjects:, landing:)
    title = landing_theme.meta_title.presence || landing_theme.title
    description = landing_theme.meta_description.presence || landing_theme.description

    meta(title: title, description: description)
    add_page_schema(page_schema(title: title, description: description))
    add_page_schema(item_list_schema(
                      name: t('landings.landings.seo.advisor_for', title: landing_theme.title).capitalize,
                      description: description,
                      items: prepare_subjects_schema_items(landing_subjects, landing.slug),
                      service_type: "Service"
                    ))
    set_theme_partner_institutions(landing_theme)
  end

  def setup_landing_subject_seo_schemas(landing_subject:)
    temoignage = TemoignageGenerator.new(landing_subject.slug)
    if temoignage.published?
      add_page_schema(review_schema(
                        author: temoignage.author,
                        content: temoignage.content,
                        index: 1
                      ))
    end
    set_theme_partner_institutions(landing_subject.landing_theme)
  end
end
