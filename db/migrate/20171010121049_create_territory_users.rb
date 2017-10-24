# frozen_string_literal: true

class CreateTerritoryUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :territory_users do |t|
      t.references :territory, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
