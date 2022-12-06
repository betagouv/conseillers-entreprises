module ApiConsumption::Agregators
  class Company
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
      REQUESTS.each_with_object(base_hash) do |request, hash|
        response = request.new(@siren).call
        hash["entreprise"].deep_merge! response
      end
    end

    def base_hash
      @base_hash ||= ApiEntreprise::Entreprise::Base.new(@siren).call
    end
  end
end
