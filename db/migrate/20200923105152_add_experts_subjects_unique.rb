class AddExpertsSubjectsUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :experts_subjects, [:expert_id, :institution_subject_id], unique: true
  end
end
