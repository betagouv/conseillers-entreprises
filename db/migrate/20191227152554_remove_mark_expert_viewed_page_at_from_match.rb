class RemoveMarkExpertViewedPageAtFromMatch < ActiveRecord::Migration[6.0]
  def change
    remove_column :matches, :expert_viewed_page_at, :datetime
  end
end
