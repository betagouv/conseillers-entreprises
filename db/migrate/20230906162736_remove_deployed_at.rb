class RemoveDeployedAt < ActiveRecord::Migration[7.0]
  def change
    remove_column :territories, :deployed_at, :datetime, precision: nil
    remove_column :solicitations, :created_in_deployed_region, :boolean, default: true
  end
end
