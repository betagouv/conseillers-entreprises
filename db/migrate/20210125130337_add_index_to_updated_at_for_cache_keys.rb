class AddIndexToUpdatedAtForCacheKeys < ActiveRecord::Migration[6.0]
  def change
    add_index :institutions, :updated_at
    add_index :institutions_subjects, :updated_at
    add_index :themes, :updated_at
    add_index :antennes, :updated_at
  end
end
