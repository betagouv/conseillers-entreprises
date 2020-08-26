class AddInstitutionAndAntenneDeletedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :deleted_at, :datetime
    add_column :antennes, :deleted_at, :datetime

    add_index :institutions, :deleted_at
    add_index :antennes, :deleted_at
    add_index :experts, :deleted_at # Was missing for some reason
  end
end
