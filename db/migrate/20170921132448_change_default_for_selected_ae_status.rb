# frozen_string_literal: true

class ChangeDefaultForSelectedAeStatus < ActiveRecord::Migration[5.1]
  def up
    change_column :selected_assistances_experts, :status, :integer, default: 0
  end

  def down
    change_column :selected_assistances_experts, :status, :integer, default: nil
  end
end
