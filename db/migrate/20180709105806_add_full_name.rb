class AddFullName < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :full_name, :string
    add_column :experts, :full_name, :string
    add_column :contacts, :full_name, :string
    execute "update users set full_name = concat(first_name, ' ', last_name)"
    execute "update experts set full_name = concat(first_name, ' ', last_name)"
    execute "update contacts set full_name = concat(first_name, ' ', last_name)"
  end

  def down
    remove_column :users, :full_name
    remove_column :experts, :full_name
    remove_column :contacts, :full_name
  end
end
