class ChangeSolicitationsForApi < ActiveRecord::Migration[7.0]
  def change
    change_column_default :solicitations, :created_in_deployed_region, from: nil, to: true
  end
end
