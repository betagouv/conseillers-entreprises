class CreateInstitution < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      t.string :name
      t.boolean :qualified_for_commerce, default: true, null: false
      t.boolean :qualified_for_artisanry, default: true, null: false
    end
    add_reference :local_offices,:institution, foreign_key: true
  end
end
