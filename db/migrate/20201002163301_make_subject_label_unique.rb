class MakeSubjectLabelUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :subjects, :label, unique: true
    add_index :institutions_subjects, [:subject_id, :institution_id, :description], unique: true, name: 'unique_institution_subject_in_institution'
  end
end
