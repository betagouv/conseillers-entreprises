# frozen_string_literal: true

class CreateExperts < ActiveRecord::Migration[5.1]
  def change
    create_table :experts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :role
      t.references :institution, foreign_key: true

      t.timestamps
    end
  end
end
