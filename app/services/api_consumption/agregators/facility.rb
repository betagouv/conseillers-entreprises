module ApiConsumption::Agregators
  class Facility
    REQUESTS = [
      ApiEntreprise::Etablissement::Base,
      ApiEntreprise::EtablissementEffectifMensuel::Base,
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
