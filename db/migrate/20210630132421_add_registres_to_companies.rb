class AddRegistresToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :inscrit_rcs, :boolean
    add_column :companies, :inscrit_rm, :boolean
  end
end
