class AddImportedAtColumns < ActiveRecord::Migration[7.2]
  DEFAULT_IMPORTED_AT = Time.utc(2001, 1, 1) # move this to somewhere permanent
  def change
    add_column :users, :imported_at, :datetime, null: false, default: DEFAULT_IMPORTED_AT
    add_column :antennes, :imported_at, :datetime, null: false, default: DEFAULT_IMPORTED_AT
  end
end
