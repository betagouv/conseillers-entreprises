class AddRegionDeployedAtFields < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :deployed_at, :datetime
    add_column :solicitations, :created_in_deployed_region, :boolean, default: false

    up_only do
      Territory.find_by(code_region: 32).update(deployed_at: "2017-07-01".to_datetime)
      Territory.find_by(code_region: 11).update(deployed_at: "2020-12-01".to_datetime)
      solicitations = Solicitation.where.not(code_region: nil).where(created_in_deployed_region: false)
      solicitations.find_each do |solicitation|
        region = solicitation.region
        next unless region
        if region.deployed? && (solicitation.created_at > region.deployed_at)
          solicitation.update(created_in_deployed_region: true)
        end
      end
    end
  end
end
