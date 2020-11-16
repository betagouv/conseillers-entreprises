class AddStatusToNeeds < ActiveRecord::Migration[6.0]
  def change
    statuses = %w[diagnosis_not_complete quo taking_care done not_for_me done_no_help done_not_reachable]
    create_enum "need_status", statuses
    add_column :needs, :status, :need_status, default: "diagnosis_not_complete", null: false
    add_index :needs, :status

    up_only do
      statuses.each do |status|
        Need.by_status(status).update_all(status: status)
      end
      Need.by_status(:sent_to_no_one).update_all(status: 'diagnosis_not_complete')
    end
  end
end
