class RemoveManagersFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :antennes, :manager_full_name, :string
    remove_column :antennes, :manager_email, :string
    remove_column :antennes, :manager_phone, :string
  end
end
