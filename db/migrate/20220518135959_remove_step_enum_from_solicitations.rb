class RemoveStepEnumFromSolicitations < ActiveRecord::Migration[7.0]
  def up
    # change status enum from postgresql to integer
    rename_column :solicitations, :status, :old_status
    add_column :solicitations, :status, :integer, default: 0

    # solicitations complétées, ni processed ni canceled
    Solicitation.where(old_status: 'processed').update_all(status: :processed, completion_step: nil)
    Solicitation.where(old_status: 'canceled').update_all(status: :canceled, completion_step: nil)
    Solicitation.where(old_status: 'in_progress').where.not(description: nil).update_all(status: :in_progress, completion_step: nil)

    # set correct status to multistep solicitation
    Solicitation.where(completion_step: :contact).update_all(status: :step_company)
    Solicitation.where(completion_step: :company).update_all(status: :step_description)

    # remove unused enums (old_status & completion_step)
    add_index :solicitations, :status
    remove_column :solicitations, :old_status
    remove_column :solicitations, :completion_step
    drop_enum :solicitation_status
  end

  # Cette migration n'est pas entierement rollbackable
  def down
    create_enum "solicitation_status", %w[in_progress processed canceled]
    add_column :solicitations, :old_status, :solicitation_status, default: 'processed'
    add_column :solicitations, :completion_step, :integer

    Solicitation.where(status: :step_description).update_all(completion_step: :company)
    Solicitation.where(status: :step_company).update_all(completion_step: :contact)

    Solicitation.where(status: :processed).update_all(old_status: 'processed')
    Solicitation.where(status: :canceled).update_all(old_status: 'canceled')
    Solicitation.where(status: :in_progress).update_all(old_status: 'in_progress')

    remove_column :solicitations, :status, :integer, default: 0
    rename_column :solicitations, :old_status, :status
  end
end
