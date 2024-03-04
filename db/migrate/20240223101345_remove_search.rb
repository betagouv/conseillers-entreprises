class RemoveSearch < ActiveRecord::Migration[7.0]
  def up
    drop_table :searches
  end

  def down
    create_table :searches do |t|
      t.string "query", null: false
      t.bigint "user_id", null: false
      t.string "label"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["query"], name: "index_searches_on_query"
      t.index ["user_id"], name: "index_searches_on_user_id"
    end
  end
end
