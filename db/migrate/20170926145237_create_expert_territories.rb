# frozen_string_literal: true

class CreateExpertTerritories < ActiveRecord::Migration[5.1]
  def change
    create_table :expert_territories do |t|
      t.references :expert, foreign_key: true
      t.references :territory, foreign_key: true

      t.timestamps
    end
  end
end
