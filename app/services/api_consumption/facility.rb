module ApiConsumption
  class Facility
    def initialize(siret, options = {})
      @siret = siret
      @options = options
    end

    def call
      model.new(params)
    end

    private

    def model
      ApiConsumption::Models::Facility
    end

    def params
      ApiConsumption::Agregators::Facility.new(@siret, @options).item_params
    end
  end
end
