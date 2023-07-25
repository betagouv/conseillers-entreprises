module ApiConsumption::Agregators
  class Company
    REQUESTS = {
      api_entreprise_entreprise: ApiEntreprise::Entreprise::Base,
      api_entreprise_effectifs_annuel: ApiEntreprise::EntrepriseEffectifAnnuel::Base,
      api_entreprise_rcs: ApiEntreprise::EntrepriseRcs::Base,
      api_entreprise_rm: ApiEntreprise::EntrepriseRm::Base,
      api_entreprise_mandataires_sociaux: ApiEntreprise::EntrepriseMandatairesSociaux::Base,
      api_rne_companies: ApiRne::Companies::Base,
    }

    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def item_params
      requests.each_with_object(base_hash.with_indifferent_access) do |request, hash|
        response = request.new(@siren).call
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
      @options&.dig(:request_keys) || [:api_entreprise_effectifs_annuel, :api_entreprise_rcs, :api_entreprise_rm, :api_entreprise_mandataires_sociaux, :api_rne_companies]
    end

    def requests
      REQUESTS.select{ |k,v| request_keys.include?(k) }.values
    end
  end
end
