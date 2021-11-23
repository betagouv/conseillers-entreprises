module ApiConsumption::Adapters
  class CompanyAndSiege
    REQUESTS = [
      ApiEntreprise::EntrepriseEffectifMensuel::Base,
      ApiEntreprise::EntrepriseRcs::Base,
      ApiEntreprise::EntrepriseRm::Base,
    ]

    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def item_params
      base_hash = ApiEntreprise::Entreprise::Base.new(@siren).call
      REQUESTS.each_with_object(base_hash) do |request, hash|
        response = request.new(@siren).call
        hash["entreprise"].deep_merge! response
      end
    end
  end
end
