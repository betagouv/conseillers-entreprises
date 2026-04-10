module SeoHelper
  include Seo::BaseSchemas
  include Seo::ContentSchemas
  include Seo::DataPreparation

  def page_schema(title:, description:, url: nil, breadcrumb: false, main_entity_id: nil)
    page_url = url || request.original_url
    schema = {
      '@type': "WebPage",
      '@id': "#{page_url}#webpage",
      name: strip_tags(title),
      url: page_url,
      description: strip_tags(description),
      image: image_url('logo-ce.png'),
      inLanguage: "fr-FR",
      isPartOf: { '@id': "#{root_url}#website" }
    }

    # Lier au breadcrumb si demandé
    schema["breadcrumb"] = { '@id': "#{page_url}#breadcrumb" } if breadcrumb

    # Lier à l'entité principale (FAQ, Article, etc.) si fournie
    schema["mainEntity"] = { '@id': main_entity_id } if main_entity_id.present?

    schema
  end

  def add_page_schema(schema)
    request.env['page_schemas'] ||= []
    request.env['page_schemas'] << schema
    nil
  end

  def set_theme_partner_institutions(landing_theme)
    request.env['theme_partner_institutions'] = theme_partner_institutions(landing_theme)
    nil
  end

  def schema_org_tag(data)
    content_tag(:script, type: 'application/ld+json') do
      raw(data.to_json.gsub('</', '<\/"'))
    end
  end

  def schema_graph(*schemas)
    {
      '@context': "https://schema.org",
      '@graph': schemas.flatten.compact
    }
  end

  def schema_org
    institutions = request.env['theme_partner_institutions']

    # Collecter tous les schémas : organization en premier (pour les références @id), puis les autres
    all_schemas = [
      government_organization_schema,
      website_schema,
      government_service_schema(institutions: institutions),
      area_served_schema,
      business_audience_schema,
      free_offer_schema
    ]

    # Récupérer les schémas ajoutés via add_page_schema
    if request.env['page_schemas'].present?
      all_schemas += request.env['page_schemas']
    end

    schema_org_tag(schema_graph(*all_schemas))
  end
end
