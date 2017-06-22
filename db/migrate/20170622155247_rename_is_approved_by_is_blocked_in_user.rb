# frozen_string_literal: true

class RenameIsApprovedByIsBlockedInUser < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :is_approved, :is_blocked
  end
end
