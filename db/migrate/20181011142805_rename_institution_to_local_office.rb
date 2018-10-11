class RenameInstitutionToLocalOffice < ActiveRecord::Migration[5.2]
  def change
    rename_table :institutions, :local_offices
    rename_column :experts, :institution_id, :local_office_id
  end
end
