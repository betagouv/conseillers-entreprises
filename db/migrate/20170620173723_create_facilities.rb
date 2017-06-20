# frozen_string_literal: true

class CreateFacilities < ActiveRecord::Migration[5.1]
  def change
    create_table :facilities do |t|
      t.references :company, foreign_key: true
      t.string :siret
      t.string :postal_code

      t.timestamps
    end
  end
end
