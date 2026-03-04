class AddMissingIndexesForSolicitationsPerformance < ActiveRecord::Migration[7.2]
  def change
    # index for get_facilities_for_email_and_sirets
    add_index :contacts, :email unless index_exists?(:contacts, :email)
    add_index :diagnoses, [:facility_id, :step] unless index_exists?(:diagnoses, [:facility_id, :step])
  end
end
