module ApiConsumption
  class Facility
    # options : model / base_key / request_keys
    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def call
      model.new(params["etablissement"])
    end

    private

    def model
      @options&.dig(:model) || ApiConsumption::Models::Facility::ApiEntreprise
    end

    def params
      ApiConsumption::Agregators::Facility.new(@siret, @options).item_params
    end
  end
end
