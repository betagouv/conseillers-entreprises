class CreateSubjectsTerritories < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects_territories do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :territory, null: false, foreign_key: true

      t.timestamps
    end
  end
end
