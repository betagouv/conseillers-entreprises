module SeoHelper

	def home_schema
		{
        "@context": "https://schema.org",
        "@type": "WebPage",
        "name": "#{t('landings.landings.home.meta.title')}",
        "url": "#{canonical_url}",
        "description": "#{t('landings.landings.home.meta.description')}",
        "image": "#{image_url('logo-ce.png')}",
        "isPartOf":{
          "@type": "WebSite",
          "name": "Conseillers-Entreprises",
          "url": "#{canonical_url}",
          "image": "#{image_url('logo-ce.png')}",
          "publisher":{
            "@type": "GovernmentOrganization",
            "name": "Conseillers-Entreprises",
            "url": "#{canonical_url}",
            "logo": "#{image_url('logo-ce.png')}",
            "email": "#{ENV['APPLICATION_EMAIL']}"
          }
        }
      }.to_json
	end

end