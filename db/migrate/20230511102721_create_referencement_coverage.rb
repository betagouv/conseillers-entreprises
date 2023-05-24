class CreateReferencementCoverage < ActiveRecord::Migration[7.0]
  def change
    create_table :referencement_coverages do |t|
      t.references :antenne, null: false, foreign_key: true
      t.references :institution_subject, null: false, foreign_key: true
      t.string :coverage
      t.integer :anomalie
      t.json :anomalie_details

      t.timestamps
    end
  end
end
