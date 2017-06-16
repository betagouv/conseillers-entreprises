# frozen_string_literal: true

class AddTitleToAssistance < ActiveRecord::Migration[5.1]
  def change
    add_column :assistances, :title, :string
    add_reference :assistances, :company, foreign_key: true
  end
end
