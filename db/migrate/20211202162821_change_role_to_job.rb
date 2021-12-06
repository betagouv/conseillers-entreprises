class ChangeRoleToJob < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :role, :job
    rename_column :experts, :role, :job
  end
end
