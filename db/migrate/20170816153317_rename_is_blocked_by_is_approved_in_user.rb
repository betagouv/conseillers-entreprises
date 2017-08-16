# frozen_string_literal: true

class RenameIsBlockedByIsApprovedInUser < ActiveRecord::Migration[5.1]
  def up
    rename_column :users, :is_blocked, :is_approved
    User.update_all('is_approved = NOT is_approved')
  end

  def down
    rename_column :users, :is_approved, :is_blocked
    User.update_all('is_blocked = NOT is_blocked')
  end
end
