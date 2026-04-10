module Seo
  module BaseSchemas
    extend ActiveSupport::Concern

    # Schémas Schema.org de base pour le service gouvernemental

    def service_output_schema
      {
        '@type': "Thing",
        name: I18n.t('landings.landings.seo.service_output')
      }
    end

    def government_service_schema(institutions: nil)
      providers = [{ '@id': "#{root_url}#organization" }]
      providers += partner_organizations_schema(institutions: institutions)

      {
        '@type': "GovernmentService",
        '@id': "#{root_url}#service",
        name: I18n.t('landings.landings.seo.service_name'),
        description: I18n.t('landings.landings.seo.service_description'),
        url: root_url,
        serviceType: I18n.t('landings.landings.seo.business_support_service'),
        provider: providers,
        areaServed: { '@id': "#{root_url}#areaserved" },
        audience: { '@id': "#{root_url}#audience" },
        offers: { '@id': "#{root_url}#offer" },
        category: [I18n.t('landings.landings.seo.business_support'), I18n.t('landings.landings.seo.public_service'), I18n.t('landings.landings.seo.free_advice')],
        jurisdiction: {
          '@type': "AdministrativeArea",
          name: I18n.t('landings.landings.seo.country_france')
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
        name: I18n.t('landings.landings.seo.service_name'),
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
        name: I18n.t('landings.landings.seo.service_name'),
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
        name: I18n.t('landings.landings.seo.country_france')
      }
    end

    def business_audience_schema
      {
        '@type': "BusinessAudience",
        '@id': "#{root_url}#audience",
        audienceType: I18n.t('landings.landings.seo.audience_type')
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
