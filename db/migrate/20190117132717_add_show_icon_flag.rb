class AddShowIconFlag < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :show_icon, :boolean, default: true
    add_column :antennes, :show_icon, :boolean, default: true
  end
end
