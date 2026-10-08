class AddProconnectSubToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :proconnect_sub, :string
    add_index :users, :proconnect_sub, unique: true
  end
end
