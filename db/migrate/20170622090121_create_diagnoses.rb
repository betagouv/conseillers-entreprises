# frozen_string_literal: true

class CreateDiagnoses < ActiveRecord::Migration[5.1]
  def change
    create_table :diagnoses do |t|
      t.references :visit, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
