class AddFlagsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :flags, :jsonb, default: {}
  end
end
