class CreateLandings < ActiveRecord::Migration[5.2]
  def change
    create_table :landings do |t|
      t.string :slug, null: false
      t.jsonb :content, default: {}
      t.timestamps
    end
  end
end
