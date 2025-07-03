module ApiConsumption::Agregators
  class Facility
    REQUESTS = {
      api_entreprise_etablissement: Api::ApiEntreprise::Etablissement::Base,
      api_entreprise_effectifs: Api::ApiEntreprise::EtablissementEffectifMensuel::Base,
      opco_cfadock: Api::Cfadock::Opco,
      opco_fc: Api::FranceCompetence::Siret::Base,
      api_rne_companies: Api::Rne::Companies::Base,
      api_recherche_entreprise: Api::RechercheEntreprises::Search::Siret,
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
      @options&.dig(:request_keys) || REQUESTS.keys
    end

    def requests
      REQUESTS.slice(*request_keys).values
    end
  end
end
