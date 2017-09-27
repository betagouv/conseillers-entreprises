# frozen_string_literal: true

class CreateTerritoryCities < ActiveRecord::Migration[5.1]
  def change
    create_table :territory_cities do |t|
      t.string :city_code
      t.references :territory, foreign_key: true

      t.timestamps
    end
  end
end
