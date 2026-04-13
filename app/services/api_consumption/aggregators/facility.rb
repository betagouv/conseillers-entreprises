module ApiConsumption::Aggregators
  class Facility
    REQUESTS = {
      api_entreprise_etablissement: Api::ApiEntreprise::Etablissement::Base, # raises technical error in case of failure because severity is major
      api_entreprise_effectifs: Api::ApiEntreprise::EtablissementEffectifMensuel::Base,
      opco_fc: Api::FranceCompetence::Siret::Base,
      api_rne_companies: Api::Rne::Companies::Base,
      api_recherche_entreprise: Api::RechercheEntreprises::Search::Siret::Base,
    }

    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def item_params
      Parallel.map(request_keys, in_threads: request_keys.size) do |request_key|
        request_klass = REQUESTS[request_key]
        begin
          request_klass.new(@siret).call
        rescue StandardError => e
          { errors: { unreachable_apis: {request_key => e.message} } }
        end
      end.each_with_object(base_hash.with_indifferent_access) do |response, hash|
        hash["etablissement"].deep_merge! response
      end
    end

    private

    def base_key
      @options&.dig(:base_key) || :api_entreprise_etablissement
    end

    def base_hash
      @base_hash ||= REQUESTS[base_key].new(@siret).call
    end

    def request_keys
      @options&.dig(:request_keys) || REQUESTS.keys.excluding(base_key)
    end

    def requests
      REQUESTS.slice(*request_keys).values
    end
  end
end
