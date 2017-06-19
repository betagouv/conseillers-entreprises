# frozen_string_literal: true

class ChangeVisitVisiteeForeignKeyWithContact < ActiveRecord::Migration[5.1]
  def up
    Visit.destroy_all
    remove_foreign_key :visits, column: :visitee_id
    add_foreign_key :visits, :contacts, column: :visitee_id
  end

  def down
    Visit.destroy_all
    remove_foreign_key :visits, column: :visitee_id
    add_foreign_key :visits, :users, column: :visitee_id
  end
end
