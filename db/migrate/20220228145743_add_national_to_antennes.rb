class AddNationalToAntennes < ActiveRecord::Migration[6.1]
  def change
    add_column :antennes, :nationale, :boolean, default: false, null: false
  end
end
