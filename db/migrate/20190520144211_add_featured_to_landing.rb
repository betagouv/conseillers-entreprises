class AddFeaturedToLanding < ActiveRecord::Migration[5.2]
  def change
    add_column :landings, :featured_on_home, :boolean, default: false
    add_column :landings, :home_title, :string, default: false
    add_column :landings, :home_description, :text, default: false
    add_column :landings, :home_sort_order, :integer
  end
end
