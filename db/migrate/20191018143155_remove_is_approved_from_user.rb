class RemoveIsApprovedFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_approved, :boolean, default: false, null: false
  end
end
