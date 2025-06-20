class AddExternalToCooperations < ActiveRecord::Migration[7.2]
  def change
    add_column :cooperations, :external, :boolean, default: false
  end
end
