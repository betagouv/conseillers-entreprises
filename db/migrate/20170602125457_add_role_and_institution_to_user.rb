# frozen_string_literal: true

class AddRoleAndInstitutionToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :institution, :string
    add_column :users, :role, :string
  end
end
