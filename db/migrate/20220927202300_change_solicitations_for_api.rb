class ChangeSolicitationsForApi < ActiveRecord::Migration[7.0]
  def up
    change_column_default :solicitations, :created_in_deployed_region, from: nil, to: true

    add_column :landings, :integration, :integer, default: 0
    Landing.where(iframe: true).update_all(integration: :iframe)
    remove_column :landings, :iframe
  end

  def down
    add_column :landings, :iframe, :boolean, default: false
    Landing.where(integration: :iframe).update_all(iframe: true)
    remove_column :landings, :integration, :integer, default: 0

    change_column_default :solicitations, :created_in_deployed_region, from: true, to: nil
  end
end
