class AddRegionNameToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :region_name, :string
  end
end
