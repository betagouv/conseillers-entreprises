module ApiConsumption::Agregators
  class Facility
    REQUESTS = {
      api_entreprise_etablissement: ApiEntreprise::Etablissement::Base,
      api_entreprise_effectifs: ApiEntreprise::EtablissementEffectifMensuel::Base,
      opco: ApiCfadock::Opco,
      opco_fc: ApiFranceCompetence::Siret::Base
    }

    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def item_params
      requests.each_with_object(base_hash.with_indifferent_access) do |request, hash|
        response = request.new(@siret).call
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
      @options&.dig(:request_keys) || [:api_entreprise_effectifs, :opco, :opco_fc]
    end

    def requests
      REQUESTS.select{ |k,v| request_keys.include?(k) }.values
    end
  end
end
