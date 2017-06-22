# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170622141733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "assistances", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "question_id"
    t.string "title"
    t.bigint "company_id"
    t.text "email_specific_sentence"
    t.integer "county"
    t.integer "geographic_scope"
    t.index ["company_id"], name: "index_assistances_on_company_id"
    t.index ["question_id"], name: "index_assistances_on_question_id"
    t.index ["user_id"], name: "index_assistances_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "siren"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "phone_number"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "role"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "company_id"
    t.string "siret"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_facilities_on_company_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailto_logs", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "visit_id"
    t.bigint "assistance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assistance_id"], name: "index_mailto_logs_on_assistance_id"
    t.index ["question_id"], name: "index_mailto_logs_on_question_id"
    t.index ["visit_id"], name: "index_mailto_logs_on_visit_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_questions_on_category_id"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.string "query"
    t.integer "user_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_approved", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "contact_page_order"
    t.string "contact_page_role"
    t.string "phone_number"
    t.string "institution"
    t.string "role"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_approved"], name: "index_users_on_is_approved"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "advisor_id"
    t.bigint "visitee_id"
    t.date "happened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["advisor_id"], name: "index_visits_on_advisor_id"
    t.index ["company_id"], name: "index_visits_on_company_id"
    t.index ["visitee_id"], name: "index_visits_on_visitee_id"
  end

  add_foreign_key "assistances", "companies"
  add_foreign_key "assistances", "questions"
  add_foreign_key "assistances", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "facilities", "companies"
  add_foreign_key "mailto_logs", "assistances"
  add_foreign_key "mailto_logs", "questions"
  add_foreign_key "mailto_logs", "visits"
  add_foreign_key "questions", "categories"
  add_foreign_key "searches", "users"
  add_foreign_key "visits", "companies"
  add_foreign_key "visits", "contacts", column: "visitee_id"
  add_foreign_key "visits", "users", column: "advisor_id"
end
