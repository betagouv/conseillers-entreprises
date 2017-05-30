# frozen_string_literal: true

class RenameUserApprovedInIsApproved < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :approved, :is_approved
  end
end
