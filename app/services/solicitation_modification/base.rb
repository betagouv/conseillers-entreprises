module SolicitationModification
  class Base
    def initialize(solicitation = Solicitation.new, params)
      @params = format_params(params)
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

    def format_params(params)
      params
    end

    def check_in_deployed_region
      @params = @params.merge(created_in_deployed_region: from_deployed_territory?)
    end

    # Methode a surcharger
    def from_deployed_territory?
      code_region = @params[:code_region] || @solicitation.code_region
      if @solicitation.persisted?
        code_region.present? && Territory.deployed_codes_regions.include?(code_region.to_i) && (@solicitation.created_at > solicitation_territory(code_region).deployed_at)
      else
        code_region.present? && Territory.deployed_codes_regions.include?(@params[:code_region].to_i)
      end
    end

    # on gère automatiquement les étapes du formulaire de création d'une solicitation
    def manage_completion_step
      return if @solicitation.step_complete?
      next_possible_events = @solicitation.aasm(:status).events(permitted: true).map(&:name)
      @solicitation.send(next_possible_events.first) unless next_possible_events.empty?
    end
  end
end
