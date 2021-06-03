module SolicitationModification
  class UpdateAllCreatedInDeployedRegion
    def self.call(solicitations = Solicitation.where.not(code_region: nil).where(created_in_deployed_region: false))
      self.new(solicitations).call
    end

    def initialize(solicitations)
      @solicitations = solicitations
    end

    def call
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
