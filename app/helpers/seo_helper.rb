module SeoHelper
  def page_schema(title:, description:, url: nil, with_breadcrumb: true)
    page_url = url || request.original_url
    schema = {
      "@type": "WebPage",
      "@id": "#{page_url}#webpage",
      "name": title,
      "url": page_url,
      "description": description,
      "image": image_url('logo-ce.png'),
      "inLanguage": "fr-FR",
      "isPartOf": { "@id": "#{root_url}#website" }
    }
    
    # Lier au breadcrumb si présent
    schema["breadcrumb"] = { "@id": "#{page_url}#breadcrumb" } if with_breadcrumb
    
    schema
  end

  def add_page_schema(schema)
    @page_schemas ||= []
    @page_schemas << schema
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
    # Collecter tous les schémas : organization en premier (pour les références @id), puis les autres
    all_schemas = [government_organization_schema, website_schema, government_service_schema]
    all_schemas += Array.wrap(@page_schemas) if defined?(@page_schemas) && @page_schemas.present?

    schema_org_tag(schema_graph(*all_schemas))
  end

  def government_service_schema
    {
      "@type": "GovernmentService",
      "@id": "#{root_url}#service",
      "name": "Conseillers-Entreprises Service Public",
      "description": "Service public d'accompagnement gratuit pour les TPE et PME en France",
      "url": root_url,
      "serviceType": "Conseil aux entreprises",
      "provider": { "@id": "#{root_url}#organization" },
      "areaServed": {
        "@type": "Country",
        "name": "France"
      },
      "audience": {
        "@type": "BusinessAudience",
        "audienceType": "TPE et PME"
      },
      "availableChannel": {
        "@type": "ServiceChannel",
        "serviceUrl": root_url,
        "availableLanguage": "fr"
      }
    }
  end

  def government_organization_schema
    {
      "@type": "GovernmentOrganization",
      "@id": "#{root_url}#organization",
      "name": "Conseillers-Entreprises Service Public",
      "url": root_url,
      "logo": image_url('logo-ce.png'),
      "contactPoint": {
        "@type": "ContactPoint",
        "email": ENV['APPLICATION_EMAIL'],
        "contactType": "customer service",
        "availableLanguage": "French"
      }
    }
  end

  def website_schema
    {
      '@type': "WebSite",
      '@id': "#{root_url}#website",
      name: "Conseillers-Entreprises Service Public",
      url: root_url,
      image: image_url('logo-ce.png'),
      inLanguage: "fr-FR",
      publisher: { '@id': "#{root_url}#organization" }
    }
  end

  def breadcrumb_schema(items)
    return nil if items.blank?

    {
      '@type': "BreadcrumbList",
      '@id': "#{request.original_url}#breadcrumb",
      itemListElement: items.map.with_index do |item, index|
        {
          '@type': "ListItem",
          position: index + 1,
          name: item[:name],
          item: item[:url]
        }
      end
    }
  end
end
