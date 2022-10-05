class AddCategoryToBadges < ActiveRecord::Migration[7.0]
  def change
    add_column :badges, :category, :integer

    up_only do
      Badge.update_all(category: 0)
    end

    change_column :badges, :category, :integer, null: false
  end
end
