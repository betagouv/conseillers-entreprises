class AddDeletedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    # We want emails to be unique, but allow nil values: let’s use a partial index
    change_column_null :users, :email, true
    remove_index :users, :email
    add_index :users, :email, unique: true, where: 'email != NULL'
  end
end
