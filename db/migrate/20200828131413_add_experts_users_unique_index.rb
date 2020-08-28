class AddExpertsUsersUniqueIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :experts_users, [:expert_id, :user_id], unique: true
  end
end
