# frozen_string_literal: true

class AddAddedByAdvisorToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :added_by_advisor, :boolean, default: false, null: false
  end
end
