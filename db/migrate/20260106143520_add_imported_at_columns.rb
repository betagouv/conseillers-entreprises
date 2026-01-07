class AddImportedAtColumns < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :imported_at, :datetime
    add_column :antennes, :imported_at, :datetime
  end
end
