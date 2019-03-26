class PreventNullCategories < ActiveRecord::Migration[5.2]
  def change
    change_column_null :questions, :category_id, false
  end
end
