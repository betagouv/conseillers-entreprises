module Seo
  module BaseSchemas
    extend ActiveSupport::Concern

    # Schémas Schema.org de base pour le service gouvernemental

    def service_output_schema
      {
        '@type': "Thing",
        name: "Être rappelé par le conseiller qui peut vous aider dans les 5 jours"
      }
    end

    def government_service_schema(institutions: nil)
      providers = [{ '@id': "#{root_url}#organization" }]
      providers += partner_organizations_schema(institutions: institutions)

      {
        '@type': "GovernmentService",
        '@id': "#{root_url}#service",
        name: "Conseillers-Entreprises Service Public",
        description: "Service public d'accompagnement pour les TPE et PME en France. Un réseau de 10 000 conseillers au sein de 40 administrations et opérateurs de l'État à votre disposition.",
        url: root_url,
        serviceType: "Conseil aux entreprises",
        provider: providers,
        areaServed: { '@id': "#{root_url}#areaserved" },
        audience: { '@id': "#{root_url}#audience" },
        offers: { '@id': "#{root_url}#offer" },
        category: ["Accompagnement entreprise", "Service public", "Conseil gratuit"],
        jurisdiction: {
          '@type': "AdministrativeArea",
          name: "France"
        },
        serviceOutput: service_output_schema,
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
  end
end
