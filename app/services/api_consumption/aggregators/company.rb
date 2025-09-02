module ApiConsumption::Aggregators
  class Company
    REQUESTS = {
      api_entreprise_entreprise: Api::ApiEntreprise::Entreprise::Base,
      api_entreprise_effectifs_annuel: Api::ApiEntreprise::EntrepriseEffectifAnnuel::Base,
      api_entreprise_mandataires_sociaux: Api::ApiEntreprise::EntrepriseMandatairesSociaux::Base,
      api_rne_companies: Api::Rne::Companies::Base,
    }

    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def item_params
      Parallel.map(requests, in_threads: requests.size) do |request|
        request.new(@siren).call
      end.each_with_object(base_hash.with_indifferent_access) do |response, hash|
        hash["entreprise"].deep_merge! response
      end
    end

    private

    def base_key
      @options&.dig(:base_key) || :api_entreprise_entreprise
    end

    def base_hash
      @base_hash ||= REQUESTS[base_key].new(@siren).call
    end

    def request_keys
      @options&.dig(:request_keys) || REQUESTS.keys.excluding(base_key)
    end

    def requests
      REQUESTS.slice(*request_keys).values
    end
  end
end
