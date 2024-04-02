class AddIndependantToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :independant, :boolean, default: false
  end
end
