class CreateCommunes < ActiveRecord::Migration[5.2]
  def change
    create_table :communes do |t|
      t.string :insee_code
      t.index :insee_code, unique: true

      t.timestamps
    end

    add_reference :territory_cities, :commune, foreign_key: true
    add_reference :facilities, :commune, foreign_key: true
  end
end
