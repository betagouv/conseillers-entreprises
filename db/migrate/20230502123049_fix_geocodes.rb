class FixGeocodes < ActiveRecord::Migration[7.0]
  def change
    remove_index :territories, :code_region
    add_index :territories, :code_region, unique: true
  end
end
