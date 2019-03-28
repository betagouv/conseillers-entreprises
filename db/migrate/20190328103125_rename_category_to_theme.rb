class RenameCategoryToTheme < ActiveRecord::Migration[5.2]
  def change
    rename_table :categories, :themes
    rename_column :questions, :category_id, :theme_id
  end
end
