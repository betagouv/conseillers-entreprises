class CreateExpertsSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :experts_subjects do |t|
      t.string :description
      t.references :expert, foreign_key: true
      t.references :institution_subject, foreign_key: true
    end
  end
end
