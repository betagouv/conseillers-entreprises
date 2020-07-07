class AddShowOnListToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :show_on_list, :boolean, default: false
  end
end
