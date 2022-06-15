class RemoveFlagsToUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :flags, :jsonb, default: {}
    remove_column :experts, :flags, :jsonb, default: {}
  end
end
