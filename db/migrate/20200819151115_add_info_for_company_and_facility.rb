class AddInfoForCompanyAndFacility < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :date_de_creation, :date
    add_column :facilities, :naf_libelle, :string
  end
end
