class RemoveFeaturedOnHomeToLanding < ActiveRecord::Migration[6.0]
  def change
    remove_column :landings, :featured_on_home
  end
end
