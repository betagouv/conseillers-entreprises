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
        if firmapi_json.blank? || firmapi_json.companies.empty?
          nil
        end
        firmapi_json.parsed_companies
      end
    end
  end
end
