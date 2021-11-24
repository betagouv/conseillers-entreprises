class CreateMatchFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :match_filters do |t|
      t.string :accepted_naf_codes, array: true
      t.integer :effectif_min
      t.integer :effectif_max
      t.integer :min_years_of_existence
      t.references :subject, foreign_key: true, null: true
      t.references :antenne, foreign_key: true, null: true
      t.timestamps
    end
  end
end
