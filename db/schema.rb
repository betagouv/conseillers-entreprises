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

ActiveRecord::Schema.define(version: 2019_11_21_101634) do

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
    t.index ["name", "institution_id"], name: "index_antennes_on_name_and_institution_id", unique: true
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
    t.string "code_effectif"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "role"
    t.bigint "company_id", null: false
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
    t.bigint "advisor_id", null: false
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
    t.string "phone_number", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token"
    t.string "full_name"
    t.bigint "antenne_id", null: false
    t.boolean "is_global_zone", default: false
    t.text "reminders_notes"
    t.index ["access_token"], name: "index_experts_on_access_token"
    t.index ["antenne_id"], name: "index_experts_on_antenne_id"
    t.index ["email"], name: "index_experts_on_email"
  end

  create_table "experts_skills", force: :cascade do |t|
    t.bigint "skill_id", null: false
    t.bigint "expert_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expert_id"], name: "index_experts_skills_on_expert_id"
    t.index ["skill_id"], name: "index_experts_skills_on_skill_id"
  end

  create_table "experts_subjects", force: :cascade do |t|
    t.string "description"
    t.bigint "expert_id"
    t.bigint "institution_subject_id"
    t.index ["expert_id"], name: "index_experts_subjects_on_expert_id"
    t.index ["institution_subject_id"], name: "index_experts_subjects_on_institution_subject_id"
  end

  create_table "experts_users", id: false, force: :cascade do |t|
    t.bigint "expert_id", null: false
    t.bigint "user_id", null: false
    t.index ["expert_id"], name: "index_experts_users_on_expert_id"
    t.index ["user_id"], name: "index_experts_users_on_user_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "siret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "naf_code"
    t.string "readable_locality"
    t.bigint "commune_id", null: false
    t.string "code_effectif"
    t.index ["commune_id"], name: "index_facilities_on_commune_id"
    t.index ["company_id"], name: "index_facilities_on_company_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "need_id"
    t.bigint "expert_id"
    t.bigint "user_id"
    t.index ["expert_id"], name: "index_feedbacks_on_expert_id"
    t.index ["need_id"], name: "index_feedbacks_on_need_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "antennes_count"
    t.boolean "show_icon", default: true
    t.index ["name"], name: "index_institutions_on_name", unique: true
  end

  create_table "institutions_subjects", force: :cascade do |t|
    t.string "description"
    t.bigint "institution_id"
    t.bigint "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "index_institutions_subjects_on_institution_id"
    t.index ["subject_id"], name: "index_institutions_subjects_on_subject_id"
  end

  create_table "landing_topics", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "landing_sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "landing_id", null: false
    t.index ["landing_id"], name: "index_landing_topics_on_landing_id"
  end

  create_table "landings", force: :cascade do |t|
    t.string "slug", null: false
    t.jsonb "content", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "featured_on_home", default: false
    t.string "home_title", default: "f"
    t.text "home_description", default: "f"
    t.integer "home_sort_order"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expert_full_name"
    t.string "expert_institution_name"
    t.string "skill_title"
    t.datetime "expert_viewed_page_at"
    t.integer "status", default: 0, null: false
    t.datetime "taken_care_of_at"
    t.datetime "closed_at"
    t.bigint "expert_id"
    t.bigint "skill_id"
    t.bigint "subject_id"
    t.index ["expert_id"], name: "index_matches_on_expert_id"
    t.index ["need_id"], name: "index_matches_on_need_id"
    t.index ["skill_id"], name: "index_matches_on_skill_id"
    t.index ["status"], name: "index_matches_on_status"
    t.index ["subject_id"], name: "index_matches_on_subject_id"
  end

  create_table "needs", force: :cascade do |t|
    t.bigint "diagnosis_id", null: false
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

  create_table "searches", id: :serial, force: :cascade do |t|
    t.string "query", null: false
    t.bigint "user_id", null: false
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
    t.string "siret"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "theme_id", null: false
    t.integer "interview_sort_order"
    t.datetime "archived_at"
    t.boolean "is_support", default: false
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
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "phone_number"
    t.string "role"
    t.string "full_name"
    t.bigint "antenne_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.bigint "inviter_id"
    t.integer "invitations_count", default: 0
    t.datetime "deactivated_at"
    t.datetime "deleted_at"
    t.index ["antenne_id"], name: "index_users_on_antenne_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email)::text <> NULL::text)"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "antennes", "institutions"
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
  add_foreign_key "experts", "antennes"
  add_foreign_key "experts_skills", "experts"
  add_foreign_key "experts_skills", "skills"
  add_foreign_key "experts_subjects", "experts"
  add_foreign_key "experts_subjects", "institutions_subjects"
  add_foreign_key "experts_users", "experts"
  add_foreign_key "experts_users", "users"
  add_foreign_key "facilities", "communes"
  add_foreign_key "facilities", "companies"
  add_foreign_key "feedbacks", "experts"
  add_foreign_key "feedbacks", "needs"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "institutions_subjects", "institutions"
  add_foreign_key "institutions_subjects", "subjects"
  add_foreign_key "landing_topics", "landings"
  add_foreign_key "matches", "experts"
  add_foreign_key "matches", "needs"
  add_foreign_key "matches", "skills"
  add_foreign_key "matches", "subjects"
  add_foreign_key "needs", "diagnoses"
  add_foreign_key "needs", "subjects"
  add_foreign_key "searches", "users"
  add_foreign_key "skills", "subjects"
  add_foreign_key "subjects", "themes"
  add_foreign_key "users", "antennes"
  add_foreign_key "users", "users", column: "inviter_id"
end
