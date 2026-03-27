module SeoHelper
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
    content_for(:page_schemas_json, schema.to_json + "\n")
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
    all_schemas = [
      government_organization_schema,
      website_schema,
      government_service_schema,
      area_served_schema,
      business_audience_schema,
      free_offer_schema
    ]
    
    # Récupérer les schémas ajoutés via content_for
    if content_for?(:page_schemas_json)
      page_schemas_json = content_for(:page_schemas_json).strip.split("\n")
      page_schemas = page_schemas_json.map { |json| JSON.parse(json) }
      all_schemas += page_schemas
    end

    schema_org_tag(schema_graph(*all_schemas))
  end

  def government_service_schema
    {
      '@type': "GovernmentService",
      '@id': "#{root_url}#service",
      name: "Conseillers-Entreprises Service Public",
      description: "Service public d'accompagnement gratuit pour les TPE et PME en France",
      url: root_url,
      serviceType: "Conseil aux entreprises",
      provider: { '@id': "#{root_url}#organization" },
      areaServed: { '@id': "#{root_url}#areaserved" },
      audience: { '@id': "#{root_url}#audience" },
      offers: { '@id': "#{root_url}#offer" },
      category: ["Accompagnement entreprise", "Service public", "Conseil gratuit"],
      jurisdiction: {
        '@type': "AdministrativeArea",
        name: "France"
      },
      serviceOutput: "Mise en relation avec un conseiller expert pour accompagner votre entreprise",
      termsOfService: "#{root_url}cgu",
      availableChannel: {
        '@type': "ServiceChannel",
        serviceUrl: root_url,
        availableLanguage: "fr-FR"
      }
    }
  end

  def government_organization_schema
    {
      '@type': "GovernmentOrganization",
      '@id': "#{root_url}#organization",
      name: "Conseillers-Entreprises Service Public",
      url: root_url,
      logo: image_url('logo-ce.png'),
      contactPoint: {
        '@type': "ContactPoint",
        email: ENV['APPLICATION_EMAIL'],
        contactType: "customer service",
        availableLanguage: "fr-FR"
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

  def area_served_schema
    {
      '@type': "Country",
      '@id': "#{root_url}#areaserved",
      name: "France"
    }
  end

  def business_audience_schema
    {
      '@type': "BusinessAudience",
      '@id': "#{root_url}#audience",
      audienceType: "TPE et PME"
    }
  end

  def free_offer_schema
    {
      '@type': "Offer",
      '@id': "#{root_url}#offer",
      price: "0",
      priceCurrency: "EUR",
      availability: "https://schema.org/InStock",
      priceSpecification: {
        '@type': "PriceSpecification",
        price: "0",
        priceCurrency: "EUR"
      }
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

  def item_list_schema(name:, description:, items:, service_type: "GovernmentService")
    return nil if items.blank?

    {
      '@type': "ItemList",
      '@id': "#{request.original_url}#itemlist",
      name: strip_tags(name),
      description: strip_tags(description),
      numberOfItems: items.count,
      itemListOrder: "https://schema.org/ItemListOrderAscending",
      itemListElement: items.map.with_index do |item, index|
        service_schema = {
          '@type': service_type,
          name: strip_tags(item[:name]),
          url: item[:url],
          provider: { '@id': "#{root_url}#organization" },
          serviceType: "Conseil aux entreprises",
          areaServed: { '@id': "#{root_url}#areaserved" },
          audience: { '@id': "#{root_url}#audience" },
          offers: { '@id': "#{root_url}#offer" },
          category: item[:category] || "Accompagnement entreprise",
          serviceOutput: "Mise en relation avec un conseiller expert"
        }

        service_schema["description"] = strip_tags(item[:description]) if item[:description].present?

        # Ajouter jurisdiction uniquement pour GovernmentService
        if service_type == "GovernmentService"
          service_schema["jurisdiction"] = {
            '@type': "AdministrativeArea",
            name: "France"
          }
        end

        {
          '@type': "ListItem",
          position: index + 1,
          item: service_schema
        }
      end
    }
  end

  def prepare_themes_schema_items(landing_themes, landing_slug)
    landing_themes.map do |theme|
      {
        name: theme.title,
        description: theme.description,
        url: landing_theme_url(landing_slug: landing_slug, slug: theme.slug)
      }
    end
  end

  def prepare_subjects_schema_items(landing_subjects, landing_slug)
    landing_subjects.map do |subject|
      {
        name: subject.title,
        description: subject.description,
        url: new_solicitation_url(landing_slug: landing_slug, landing_subject_slug: subject.slug)
      }
    end
  end

  def faq_page_schema(faq_items)
    return nil if faq_items.blank?

    {
      '@type': "FAQPage",
      '@id': "#{request.original_url}#faqpage",
      mainEntity: faq_items.map do |item|
        {
          '@type': "Question",
          name: strip_tags(item[:question]),
          acceptedAnswer: {
            '@type': "Answer",
            text: strip_tags(item[:answer])
          }
        }
      end
    }
  end

  def review_schema(author:, content:, index: 1, job_title: nil, company: nil, rating: nil)
    return nil if author.blank? || content.blank?

    schema = {
      '@type': "Review",
      '@id': "#{request.original_url}#review-#{index}",
      itemReviewed: { '@id': "#{root_url}#service" },
      reviewBody: strip_tags(content),
      author: {
        '@type': "Person",
        name: strip_tags(author)
      }
    }

    # Ajouter le titre et l'entreprise si fournis
    if job_title.present? || company.present?
      schema[:author]["jobTitle"] = strip_tags(job_title) if job_title.present?
      schema[:author]["worksFor"] = {
        '@type': "Organization",
        name: strip_tags(company)
      } if company.present?
    end

    # Ajouter la note si fournie
    if rating.present?
      schema["reviewRating"] = {
        '@type': "Rating",
        ratingValue: rating,
        bestRating: 5
      }
    end

    schema
  end
end
