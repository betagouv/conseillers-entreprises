class DropReferencementCoverageTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :referencement_coverages do |t|
      t.integer :anomalie
      t.json :anomalie_details
      t.string :coverage
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.bigint :antenne_id, null: false
      t.bigint :institution_subject_id, null: false
      t.index :antenne_id
      t.index :institution_subject_id
    end
  end
end
