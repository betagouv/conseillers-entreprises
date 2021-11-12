module ApiConsumption::Adapters
  class Facility

    REQUESTS = [
      ApiEntreprise::Etablissement::Etablissement::Base,
      ApiEntreprise::Etablissement::Effectifs::Base,
      ApiCfadock::Opco
    ]

    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def etablissement_params
      result_hash = REQUESTS.each_with_object({}) do |request, hash|
        response = request.new(@siret).call
        hash.deep_merge! response
      end
      result_hash
    end
  end
end
