# frozen_string_literal: true

class CreateTerritories < ActiveRecord::Migration[5.1]
  def change
    create_table :territories do |t|
      t.string :name

      t.timestamps
    end
  end
end
