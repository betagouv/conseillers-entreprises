class RemoveCommuneAndTerritory < ActiveRecord::Migration[7.2]
  def change
    # Drop join tables first to remove foreign key constraints
    drop_table :antennes_communes, if_exists: true
    drop_table :communes_experts, if_exists: true
    drop_table :communes_territories, if_exists: true
    drop_table :territories_themes, if_exists: true

    # Now we can drop the main tables
    drop_table :communes, if_exists: true
    drop_table :territories, if_exists: true

    # Remove the commune_id column from facilities
    remove_column :facilities, :commune_id, if_exists: true
  end
end
