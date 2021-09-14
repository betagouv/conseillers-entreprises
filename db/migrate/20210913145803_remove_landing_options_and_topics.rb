class RemoveLandingOptionsAndTopics < ActiveRecord::Migration[6.1]
  def up
    drop_table :landing_options
    drop_table :landing_topics
    remove_column :solicitations, :landing_options_slugs, :string
  end

  def down
    add_column :solicitations, :landing_options_slugs, :string, array: true
    create_table "landing_topics", force: :cascade do |t|
      t.string "title"
      t.text "description"
      t.integer "landing_sort_order"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "landing_id", null: false
      t.string "landing_option_slug"
      t.string "group_name"
      t.index ["landing_id"], name: "index_landing_topics_on_landing_id"
    end

    create_table :landing_options do |t|
      t.integer "landing_sort_order"
      t.bigint "landing_id"
      t.string "slug", null: false
      t.string "preselected_subject_slug"
      t.string "preselected_institution_slug"
      t.boolean "requires_full_name", default: false, null: false
      t.boolean "requires_phone_number", default: false, null: false
      t.boolean "requires_email", default: false, null: false
      t.boolean "requires_siret", default: false, null: false
      t.boolean "requires_requested_help_amount", default: false, null: false
      t.boolean "requires_location", default: false, null: false
      t.string "form_title"
      t.string "form_description"
      t.string "description_explanation"
      t.string "meta_title"
      t.index ["landing_id"], name: "index_landing_options_on_landing_id"
      t.index ["slug"], name: "index_landing_options_on_slug", unique: true
    end
  end
end
