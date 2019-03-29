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

ActiveRecord::Schema.define(version: 2019_03_29_105202) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "antennes", force: :cascade do |t|
    t.string "name"
    t.bigint "institution_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "experts_count"
    t.integer "advisors_count"
    t.boolean "show_icon", default: true
    t.index ["institution_id"], name: "index_antennes_on_institution_id"
  end

  create_table "antennes_communes", id: false, force: :cascade do |t|
    t.bigint "antenne_id", null: false
    t.bigint "commune_id", null: false
    t.index ["antenne_id"], name: "index_antennes_communes_on_antenne_id"
    t.index ["commune_id"], name: "index_antennes_communes_on_commune_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "communes", force: :cascade do |t|
    t.string "insee_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insee_code"], name: "index_communes_on_insee_code", unique: true
  end

  create_table "communes_experts", id: false, force: :cascade do |t|
    t.bigint "commune_id", null: false
    t.bigint "expert_id", null: false
    t.index ["commune_id"], name: "index_communes_experts_on_commune_id"
    t.index ["expert_id"], name: "index_communes_experts_on_expert_id"
  end

  create_table "communes_territories", force: :cascade do |t|
    t.bigint "territory_id", null: false
    t.bigint "commune_id", null: false
    t.index ["commune_id"], name: "index_communes_territories_on_commune_id"
    t.index ["territory_id"], name: "index_communes_territories_on_territory_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "siren"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "legal_form_code"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "role"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diagnoses", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "step", default: 1
    t.datetime "archived_at"
    t.bigint "advisor_id"
    t.bigint "visitee_id"
    t.bigint "facility_id"
    t.date "happened_on"
    t.index ["advisor_id"], name: "index_diagnoses_on_advisor_id"
    t.index ["archived_at"], name: "index_diagnoses_on_archived_at"
    t.index ["facility_id"], name: "index_diagnoses_on_facility_id"
    t.index ["visitee_id"], name: "index_diagnoses_on_visitee_id"
  end

  create_table "experts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token"
    t.string "full_name"
    t.bigint "antenne_id", null: false
    t.index ["access_token"], name: "index_experts_on_access_token"
    t.index ["antenne_id"], name: "index_experts_on_antenne_id"
    t.index ["email"], name: "index_experts_on_email"
  end

  create_table "experts_skills", force: :cascade do |t|
    t.bigint "skill_id"
    t.bigint "expert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expert_id"], name: "index_experts_skills_on_expert_id"
    t.index ["skill_id"], name: "index_experts_skills_on_skill_id"
  end

  create_table "experts_users", id: false, force: :cascade do |t|
    t.bigint "expert_id"
    t.bigint "user_id"
    t.index ["expert_id"], name: "index_experts_users_on_expert_id"
    t.index ["user_id"], name: "index_experts_users_on_user_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "company_id"
    t.string "siret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "naf_code"
    t.string "readable_locality"
    t.bigint "commune_id", null: false
    t.index ["commune_id"], name: "index_facilities_on_commune_id"
    t.index ["company_id"], name: "index_facilities_on_company_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "description"
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_feedbacks_on_match_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "antennes_count"
    t.boolean "show_icon", default: true
  end

  create_table "landings", force: :cascade do |t|
    t.string "slug", null: false
    t.jsonb "content", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "need_id"
    t.bigint "experts_skills_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expert_full_name"
    t.string "expert_institution_name"
    t.string "skill_title"
    t.datetime "expert_viewed_page_at"
    t.integer "status", default: 0, null: false
    t.bigint "relay_id"
    t.datetime "taken_care_of_at"
    t.datetime "closed_at"
    t.index ["experts_skills_id"], name: "index_matches_on_experts_skills_id"
    t.index ["need_id"], name: "index_matches_on_need_id"
    t.index ["relay_id"], name: "index_matches_on_relay_id"
    t.index ["status"], name: "index_matches_on_status"
  end

  create_table "needs", force: :cascade do |t|
    t.bigint "diagnosis_id"
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content"
    t.integer "matches_count"
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_needs_on_archived_at"
    t.index ["diagnosis_id"], name: "index_needs_on_diagnosis_id"
    t.index ["subject_id"], name: "index_needs_on_subject_id"
  end

  create_table "relays", force: :cascade do |t|
    t.bigint "territory_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["territory_id"], name: "index_relays_on_territory_id"
    t.index ["user_id"], name: "index_relays_on_user_id"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.string "query", null: false
    t.integer "user_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query"], name: "index_searches_on_query"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subject_id", null: false
    t.string "title"
    t.index ["subject_id"], name: "index_skills_on_subject_id"
  end

  create_table "solicitations", force: :cascade do |t|
    t.string "description"
    t.string "email"
    t.string "phone_number"
    t.jsonb "needs", default: {}
    t.jsonb "form_info", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "theme_id", null: false
    t.integer "interview_sort_order"
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_subjects_on_archived_at"
    t.index ["theme_id"], name: "index_subjects_on_theme_id"
  end

  create_table "territories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bassin_emploi", default: false, null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "interview_sort_order"
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
    t.integer "contact_page_order"
    t.string "contact_page_role"
    t.string "phone_number"
    t.string "institution"
    t.string "role"
    t.string "full_name"
    t.bigint "antenne_id"
    t.index ["antenne_id"], name: "index_users_on_antenne_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_approved"], name: "index_users_on_is_approved"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "antennes_communes", "antennes"
  add_foreign_key "antennes_communes", "communes"
  add_foreign_key "communes_experts", "communes"
  add_foreign_key "communes_experts", "experts"
  add_foreign_key "communes_territories", "communes"
  add_foreign_key "communes_territories", "territories"
  add_foreign_key "contacts", "companies"
  add_foreign_key "diagnoses", "contacts", column: "visitee_id"
  add_foreign_key "diagnoses", "facilities"
  add_foreign_key "diagnoses", "users", column: "advisor_id"
  add_foreign_key "experts_skills", "experts"
  add_foreign_key "experts_skills", "skills"
  add_foreign_key "facilities", "communes"
  add_foreign_key "facilities", "companies"
  add_foreign_key "feedbacks", "matches"
  add_foreign_key "matches", "experts_skills", column: "experts_skills_id"
  add_foreign_key "matches", "needs"
  add_foreign_key "matches", "relays"
  add_foreign_key "needs", "diagnoses"
  add_foreign_key "needs", "subjects"
  add_foreign_key "relays", "territories"
  add_foreign_key "relays", "users"
  add_foreign_key "searches", "users"
  add_foreign_key "skills", "subjects"
  add_foreign_key "subjects", "themes"
end
