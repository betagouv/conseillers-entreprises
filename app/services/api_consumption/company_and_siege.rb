module ApiConsumption
  class CompanyAndSiege
    def initialize(siren, options = {})
      @siren = siren
      @options = options
    end

    def call
      model.new(params)
    end

    private

    def model
      ApiConsumption::Models::CompanyAndSiege
    end

    def params
      ApiConsumption::Adapters::CompanyAndSiege.new(@siren, @options).item_params
    end
  end
end
