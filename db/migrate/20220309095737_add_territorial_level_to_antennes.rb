class AddTerritorialLevelToAntennes < ActiveRecord::Migration[6.1]
  def change
    levels = %w[local regional national]
    create_enum "territorial_level", levels

    add_column :antennes, :territorial_level, :territorial_level, default: 'local', null: false
    add_index :antennes, :territorial_level
    remove_column :antennes, :nationale, :boolean, default: false
  end
end
