class CreateInstitutionsSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions_subjects do |t|
      t.string :description
      t.references :institution, foreign_key: true
      t.references :subject, foreign_key: true
      t.timestamps
    end
  end
end
