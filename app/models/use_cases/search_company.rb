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
    end
  end
end
