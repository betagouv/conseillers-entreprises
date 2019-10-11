class RemoveUserContactPageOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :contact_page_order, :integer
    remove_column :users, :contact_page_role, :string
  end
end
