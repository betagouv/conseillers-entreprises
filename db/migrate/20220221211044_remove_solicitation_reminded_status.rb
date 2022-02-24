class RemoveSolicitationRemindedStatus < ActiveRecord::Migration[6.1]
  def up
    rename_column :solicitations, :status, :old_status
    create_enum "solicitation_status", %w[in_progress processed canceled]

    add_column :solicitations, :status, :solicitation_status, default: "in_progress", null: false
    add_index :solicitations, :status
    Solicitation.where(old_status: 0).update_all(status: 'in_progress')
    Solicitation.where(old_status: 1).update_all(status: 'processed')
    Solicitation.where(old_status: 2).update_all(status: 'canceled')
    Solicitation.where(old_status: 3).update_all(status: 'canceled')

    remove_column :solicitations, :old_status, :integer, default: 0
  end

  def down
    rename_column :solicitations, :status, :old_status

    add_column :solicitations, :status, :integer, default: 0
    Solicitation.where(old_status: 'in_progress').update_all(status: 0)
    Solicitation.where(old_status: 'processed').update_all(status: 1)
    Solicitation.where(old_status: 'canceled').update_all(status: 2)

    remove_enum "solicitation_status", %w[in_progress processed canceled]
    remove_column :solicitations, :old_status
  end
end
