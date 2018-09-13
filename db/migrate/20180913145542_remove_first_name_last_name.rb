class RemoveFirstNameLastName < ActiveRecord::Migration[5.2]
  # See also AddFullName, two months earlier
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :experts, :first_name, :string
    remove_column :experts, :last_name, :string
    remove_column :contacts, :first_name, :string
    remove_column :contacts, :last_name, :string
  end
end
