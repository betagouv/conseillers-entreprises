class RemoveLogosToLandings < ActiveRecord::Migration[6.1]
  def change
    remove_column :landings, :logos, :string
  end
end
