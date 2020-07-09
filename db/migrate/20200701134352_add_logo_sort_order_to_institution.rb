class AddLogoSortOrderToInstitution < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :logo_sort_order, :integer
    remove_column :institutions, :show_icon, :boolean
  end
end
