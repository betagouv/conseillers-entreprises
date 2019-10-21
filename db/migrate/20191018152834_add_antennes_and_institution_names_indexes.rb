class AddAntennesAndInstitutionNamesIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :antennes, [:name, :institution_id], unique: true
    add_index :institutions, :name, unique: true
  end
end
