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
      ApiConsumption::Models::Company
    end

    def params
      ApiConsumption::Adapters::CompanyAndSiege.new(@siren, @options).item_params
    end
  end
end
