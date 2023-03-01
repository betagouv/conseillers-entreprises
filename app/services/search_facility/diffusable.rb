module SearchFacility
  class Diffusable < Base
    def from_siren
      return blank_query if @query.blank?
      siren = FormatSiret.siren_from_query(@query[0..8])
      begin
        data_company = ApiEntreprise::Entreprise::Base.new(siren).call[:entreprise]
        data_siege = ApiEntreprise::Etablissement::Base.new(data_company["siret_siege_social"]).call[:etablissement]
        formatted_items(data_siege, data_company)
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
        data_company = ApiEntreprise::Entreprise::Base.new(siren).call[:entreprise]
        data_facility = ApiEntreprise::Etablissement::Base.new(siret).call[:etablissement]
        formatted_items(data_facility, data_company)
      rescue ApiEntreprise::ApiEntrepriseError => e
        message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
        return { items: [], error: message }
      end
    end

    private

    def formatted_items(facility, company)
      return {
        items: [ApiConsumption::Models::FacilityAutocomplete::ApiEntreprise.new({ etablissement: facility, entreprise: company })],
        error: nil
      }
    end
  end
end
