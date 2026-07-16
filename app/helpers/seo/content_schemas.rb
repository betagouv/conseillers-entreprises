module Seo
  module ContentSchemas
    # Schémas Schema.org pour le contenu (breadcrumb, FAQ, reviews, listes)

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
            serviceType: I18n.t('landings.landings.seo.business_support_service'),
            areaServed: { '@id': "#{root_url}#areaserved" },
            audience: { '@id': "#{root_url}#audience" },
            offers: { '@id': "#{root_url}#offer" },
            category: item[:category] || I18n.t('landings.landings.seo.business_support'),
            serviceOutput: service_output_schema
          }

          service_schema["description"] = strip_tags(item[:description]) if item[:description].present?

          if service_type == "GovernmentService"
            service_schema["jurisdiction"] = {
              '@type': "AdministrativeArea",
              name: I18n.t('landings.landings.seo.country_france')
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

    # Témoignage d'un conseiller : interview éditoriale publiée par le service.
    # Le conseiller est l'interviewé (le sujet), pas l'auteur : on l'expose donc en `about`
    # comme un Person rattaché à son institution (GovernmentOrganization), et l'auteur est
    # l'organisation éditrice. Ce n'est pas un avis d'utilisateur, d'où "Article" (et non "Review").
    def temoignage_article_schema(temoignage:, image:)
      return nil if temoignage.blank?

      page_url = request.original_url
      {
        '@type': "Article",
        '@id': "#{page_url}#article",
        headline: strip_tags(temoignage.title),
        description: strip_tags(temoignage.subtitle),
        image: image,
        datePublished: temoignage.initial_publication_date.in_time_zone.iso8601,
        dateModified: temoignage.publication_date.in_time_zone.iso8601,
        inLanguage: "fr-FR",
        author: { '@id': "#{root_url}#organization" },
        publisher: { '@id': "#{root_url}#organization" },
        about: [
          { '@id': "#{root_url}#service" },
          {
            '@type': "Person",
            name: temoignage.expert,
            worksFor: {
              '@type': "GovernmentOrganization",
              name: temoignage.institution
            }
          }
        ],
        isPartOf: { '@id': "#{page_url}#webpage" },
        mainEntityOfPage: { '@id': "#{page_url}#webpage" }
      }
    end

    def review_schema(author:, content:, index: 1)
      return nil if author.blank? || content.blank?

      {
        '@type': "Review",
        '@id': "#{request.original_url}#review-#{index}",
        itemReviewed: { '@id': "#{root_url}#organization" },
        reviewBody: strip_tags(content),
        author: {
          '@type': "Person",
          name: strip_tags(author)
        }
      }
    end
  end
end
