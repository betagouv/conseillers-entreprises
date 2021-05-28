module SolicitationService
  class Create
    def self.call(params)
      self.new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      check_in_deployed_region
      solicitation.save
      return solicitation
    end

    private

    def solicitation
      @solicitation ||= Solicitation.new(@params)
    end

    def check_in_deployed_region
      if @params[:code_region].present? && Territory.deployed_codes_regions.include?(@params[:code_region].to_i)
        @params = @params.merge(created_in_deployed_region: true)
      end
    end
  end
end
