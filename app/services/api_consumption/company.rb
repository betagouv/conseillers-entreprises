module ApiConsumption
  class Company
    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def call
      model.new(params["entreprise"])
    end

    private

    def model
      ApiConsumption::Models::Company::ApiEntreprise
    end

    def params
      ApiConsumption::Agregators::Company.new(@siren, @options).item_params
    end
  end
end
