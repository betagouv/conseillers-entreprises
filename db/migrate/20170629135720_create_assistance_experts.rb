# frozen_string_literal: true

class CreateAssistanceExperts < ActiveRecord::Migration[5.1]
  def change
    create_table :assistances_experts do |t|
      t.references :assistance, foreign_key: true
      t.references :expert, foreign_key: true

      t.timestamps
    end
  end
end
