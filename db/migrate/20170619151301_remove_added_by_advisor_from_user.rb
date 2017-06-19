# frozen_string_literal: true

class RemoveAddedByAdvisorFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :added_by_advisor, :boolean, default: false, null: false
  end
end
