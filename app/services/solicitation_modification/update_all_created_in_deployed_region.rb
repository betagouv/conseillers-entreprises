module SolicitationModification
  class UpdateAllCreatedInDeployedRegion
    def initialize(solicitations)
      @solicitations = solicitations
    end

    def base_call
      @solicitations.find_each do |solicitation|
        region = solicitation.region
        next unless region
        if region.deployed? && (solicitation.created_at > region.deployed_at)
          solicitation.update(created_in_deployed_region: true)
        end
      end
    end
  end
end
