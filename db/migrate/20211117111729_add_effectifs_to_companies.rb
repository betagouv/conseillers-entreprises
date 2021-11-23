class AddEffectifsToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :effectif, :float
    add_column :facilities, :effectif, :float
  end
end
