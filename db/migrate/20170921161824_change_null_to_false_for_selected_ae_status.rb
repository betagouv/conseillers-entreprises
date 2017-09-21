# frozen_string_literal: true

class ChangeNullToFalseForSelectedAeStatus < ActiveRecord::Migration[5.1]
  def up
    change_column :selected_assistances_experts, :status, :integer, default: 0, null: false
  end

  def down
    change_column :selected_assistances_experts, :status, :integer, default: 0, null: true
  end
end
