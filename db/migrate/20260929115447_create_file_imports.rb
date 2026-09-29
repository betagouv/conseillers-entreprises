class CreateFileImports < ActiveRecord::Migration[8.1]
  def change
    create_enum "file_imports_entities", ["User", "Antenne"]
    create_table :file_imports do |t|
      t.timestamps
      t.enum "entity", enum_type: "file_imports_entities", null: false
      t.belongs_to :user, index: true, null: false
      t.belongs_to :institution, index: true, null: false
    end
  end
end
