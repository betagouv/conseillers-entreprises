module ApiConsumption::Adapters
  class CompanyAndSiege
    REQUESTS = [
      # ApiEntreprise::Entreprise::Base,
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
      p "ITEM PARAMS ========================="
      p base_hash
      REQUESTS.each_with_object(base_hash) do |request, hash|
        response = request.new(@siren).call
        p response
        hash["entreprise"].deep_merge! response
        p hash["entreprise"]
        p '-------------------------------------------------'
      end
    end
  end
end
