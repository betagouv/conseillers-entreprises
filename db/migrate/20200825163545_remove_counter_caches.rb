class RemoveCounterCaches < ActiveRecord::Migration[6.0]
  def change
    remove_column :institutions, :antennes_count, :integer
    remove_column :antennes, :experts_count, :integer
    remove_column :antennes, :advisors_count, :integer
  end
end
