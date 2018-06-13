# frozen_string_literal: true

class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :selected_assistances_experts do |t|
      t.references :diagnosed_need, foreign_key: true
      t.references :assistances_experts, foreign_key: true

      t.timestamps
    end
  end
end
