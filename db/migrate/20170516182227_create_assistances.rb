# frozen_string_literal: true

class CreateAssistances < ActiveRecord::Migration[5.1]
  def change
    create_table :assistances do |t|
      t.references :answer, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
