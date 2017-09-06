# frozen_string_literal: true

module UseCases
  class SearchCompany
    class << self
      def with_siren(siren)
        token = ENV.fetch('API_ENTREPRISE_TOKEN')
        ApiEntreprise::Entreprises.new(token).fetch(siren)
      end

      def with_siret(siret)
        with_siren(siret[0, 9])
      end

      def with_name_and_county(name, county)
        firmapi_json = Firmapi::FirmsSearch.new.fetch(name, county)
        nil if firmapi_json.blank? || firmapi_json['companies'].empty?
        firmapi_json
      end
    end
  end
end
