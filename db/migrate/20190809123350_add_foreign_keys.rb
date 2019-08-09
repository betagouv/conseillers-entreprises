class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :antennes, :institutions
    add_foreign_key :experts, :antennes
    add_foreign_key :experts_users, :experts
    add_foreign_key :experts_users, :users
    add_foreign_key :users, :antennes
  end
end
