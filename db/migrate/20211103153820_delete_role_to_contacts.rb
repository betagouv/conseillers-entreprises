class DeleteRoleToContacts < ActiveRecord::Migration[6.1]
  def change
    remove_column :contacts, :role, :string
  end
end
