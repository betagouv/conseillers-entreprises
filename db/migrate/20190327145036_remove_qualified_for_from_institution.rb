class RemoveQualifiedForFromInstitution < ActiveRecord::Migration[5.2]
  def change
    remove_column :institutions, :qualified_for_artisanry, :boolean, default: true, null: false
    remove_column :institutions, :qualified_for_commerce, :boolean, default: true, null: false
  end
end
