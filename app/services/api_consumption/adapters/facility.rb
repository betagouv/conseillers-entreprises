module ApiConsumption::Adapters
  class Facility
    REQUESTS = [
      ApiEntreprise::Etablissement::Etablissement::Base,
      ApiEntreprise::Etablissement::EffectifMensuel::Base,
      ApiCfadock::Opco
    ]

    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def item_params
      REQUESTS.each_with_object({}) do |request, hash|
        response = request.new(@siret).call
        hash.deep_merge! response
      end
    end
  end
end
