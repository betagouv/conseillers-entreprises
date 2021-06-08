module SolicitationModification
  class Update < Base
    def from_deployed_territory?
      code_region = @params[:code_region] || @solicitation.code_region
      code_region.present? && solicitation_territory(code_region)&.deployed? && (@solicitation.created_at > solicitation_territory(code_region).deployed_at)
    end

    def solicitation_territory(code_region)
      @solicitation_territory || Territory.find_by(code_region: code_region)
    end
  end
end
