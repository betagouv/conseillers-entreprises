module SearchFacility
  class Diffusable < Base
    def from_siren
      return blank_query if @query.blank?
      siren = FormatSiret.siren_from_query(@query[0..8])
      begin
        data = ApiEntreprise::Entreprise::Base.new(siren).call
        formatted_item = ApiConsumption::Models::FacilityAutocomplete::ApiEntreprise.new(data)
        return { items: [formatted_item], error: nil }
      rescue ApiEntreprise::ApiEntrepriseError => e
        message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
        return { items: [], error: message }
      end
  end

    def from_siret
      return blank_query if @query.blank?
      siret = FormatSiret.siret_from_query(@query[0..13])
      siren = FormatSiret.siren_from_query(@query[0..8])
      begin
        data_etablissement = ApiEntreprise::Etablissement::Base.new(siret).call
        data_entreprise = ApiEntreprise::Entreprise::Base.new(siren).call['entreprise'].except('etablissement_siege')
        formatted_item = ApiConsumption::Models::FacilityAutocomplete::ApiEntreprise.new({ etablissement_siege: data_etablissement, entreprise: data_entreprise })
        return { items: [formatted_item], error: nil }
      rescue ApiEntreprise::ApiEntrepriseError => e
        message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
        return { items: [], error: message }
      end
    end
  end
end
