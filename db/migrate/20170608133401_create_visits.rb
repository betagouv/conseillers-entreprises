# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[5.1]
  def change
    create_table :visits do |t|
      t.references :advisor
      t.references :visitee
      t.date :happened_on

      t.timestamps
    end
    add_foreign_key :visits, :users, column: :advisor_id
    add_foreign_key :visits, :users, column: :visitee_id
  end
end
