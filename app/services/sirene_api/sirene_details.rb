# frozen_string_literal: true

module SireneApi
  class SireneDetails
    def self.details(siret)
      if !Facility.siret_is_valid(siret)
        return nil
      end
      http_response = HTTP.get(url(siret))
      hash = http_response.parse(:json)&.deep_symbolize_keys
      hash[:etablissement]
    end

    def self.url(siret)
      "https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/#{siret}"
    end
  end
end
