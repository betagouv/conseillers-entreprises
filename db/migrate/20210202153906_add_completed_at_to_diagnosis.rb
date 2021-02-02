class AddCompletedAtToDiagnosis < ActiveRecord::Migration[6.0]
  def change
    add_column :diagnoses, :completed_at, :timestamp

    up_only do
      Diagnosis.find_each do |diagnosis|
        diagnosis.update_columns(completed_at: diagnosis.old_completed_at)
      end
    end
  end
end
