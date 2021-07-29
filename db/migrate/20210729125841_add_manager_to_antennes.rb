class AddManagerToAntennes < ActiveRecord::Migration[6.1]
  def change
    add_column :antennes, :manager_full_name, :string
    add_column :antennes, :manager_email, :string
    add_column :antennes, :manager_phone, :string
  end
end
