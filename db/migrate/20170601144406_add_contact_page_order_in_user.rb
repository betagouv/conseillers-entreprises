# frozen_string_literal: true

class AddContactPageOrderInUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :contact_page_order, :integer
    add_column :users, :contact_page_role, :string
    add_column :users, :phone_number, :string
  end
end
