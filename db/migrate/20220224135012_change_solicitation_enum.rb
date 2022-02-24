class ChangeSolicitationEnum < ActiveRecord::Migration[6.1]
  def change
    rename_column :solicitations, :status, :old_status
    create_enum "solicitation_status", %w[in_progress processed canceled]

    add_column :solicitations, :status, :solicitation_status, default: "in_progress", null: false
    add_index :solicitations, :status
    Solicitation.find_each do |solicitation|
      solicitation.update_columns(status:  Solicitation.statuses.to_a[solicitation.old_status].first )
    end
    remove_column :solicitations, :old_status, :integer, default: 0
  end
end
