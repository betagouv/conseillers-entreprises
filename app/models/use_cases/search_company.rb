module UseCases
  class SearchCompany
    class << self
      def with_siren(siren, options = {})
        token = ENV.fetch('API_ENTREPRISE_TOKEN')
        ApiEntreprise::Entreprises.new(token, options).fetch(siren)
      end

      def with_siret(siret, options = {})
        with_siren(siret[0, 9], options)
      end
    end
  end
end
