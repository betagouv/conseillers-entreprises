class FixGeocodes < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { change_column :territories, :code_region, :string }
      dir.down { change_column :territories, :code_region, :integer, using: 'code_region::integer' }
    end

    remove_index :territories, :code_region
    add_index :territories, :code_region, unique: true
  end
end
