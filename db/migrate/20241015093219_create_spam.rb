class CreateSpam < ActiveRecord::Migration[7.0]
  def change
    create_table :spams do |t|
      t.string :email, null: false

      t.timestamps
    end

    up_only do
      change_column_default :badges, :color, "#000000"
    end
    add_index :badges, [:title, :category], unique: true
    add_index :spams, :email, unique: true
  end
end
