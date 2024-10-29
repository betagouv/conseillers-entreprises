module SearchFacility
  class Diffusable < Base
    def from_siren
      return blank_query if @query.blank?
      siren = FormatSiret.siren_from_query(@query[0..8])
      begin
        response = Api::Insee::SiretsBySiren::Base.new(siren).call
        items = response[:etablissements_ouverts].map do |entreprise_params|
          next if entreprise_params.blank?
          format_data(entreprise_params, response)
        end
        return { items: items, error: nil }
      # fallback si l'API Insee est en carafe
      rescue Api::UnavailableApiError => e
        from_full_text
      rescue Api::BasicError, Api::TechnicalError => e
        message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
        return { items: [], error: message }
      end
    end

    def from_siret
      return blank_query if @query.blank?
      siret = FormatSiret.siret_from_query(@query[0..13])
      begin
        response = Api::Insee::Siret::Base.new(siret).call
        items = response[:etablissements].map do |entreprise_params|
          next if entreprise_params.blank?
          format_data(entreprise_params, response)
        end
        return { items: items, error: nil }
      # pas de fallback pour le moment, on trouve pas d'API "equivalente"
      rescue Api::UnavailableApiError, Api::BasicError, Api::TechnicalError => e
        message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
        return { items: [], error: message }
      end
    end

    def format_data(entreprise_params, response)
      ApiConsumption::Models::FacilityAutocomplete::ApiInsee.new({
        nombre_etablissements_ouverts: response[:nombre_etablissements_ouverts],
        un_seul_etablissement: true,
        etablissement: entreprise_params.except('uniteLegale'),
        entreprise: entreprise_params['uniteLegale']
      })
    end
  end
end
