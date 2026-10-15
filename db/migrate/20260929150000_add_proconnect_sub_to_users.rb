class AddProconnectSubToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :proconnect_uid, :string
    add_index :users, :proconnect_uid, unique: true
  end
end
