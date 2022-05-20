module SolicitationModification
  class Base
    def initialize(solicitation = Solicitation.new, params)
      @params = params
      @solicitation = solicitation
    end

    def base_call
      check_in_deployed_region
      @solicitation.assign_attributes(@params)
      manage_completion_step
    end

    def call
      base_call
      return @solicitation
    end

    def call!
      base_call
      @solicitation.save
      return @solicitation
    end

    private

    def check_in_deployed_region
      if from_deployed_territory?
        @params = @params.merge(created_in_deployed_region: true)
      end
    end

    # Methode a surcharger
    def from_deployed_territory?
      @params[:code_region].present? && Territory.deployed_codes_regions.include?(@params[:code_region].to_i)
    end

    # on gère automatiquement les étapes du formulaire de création d'une solicitation
    def manage_completion_step
      return if @solicitation.step_complete?
      next_possible_statuses = @solicitation.aasm(:status).states(permitted: true).map(&:name)
      @solicitation.status = next_possible_statuses.first unless next_possible_statuses.empty?
    end
  end
end
