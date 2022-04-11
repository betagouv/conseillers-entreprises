class UpdateNameIndexForAntennes < ActiveRecord::Migration[6.1]
  def change
    remove_index :antennes, name: "index_antennes_on_name_and_institution_id"
    add_index :antennes, ["name", "deleted_at", "institution_id"]
  end
end
