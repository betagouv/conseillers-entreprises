# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_31_095237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_enum :actions_categories, [
    "poke",
    "recall",
    "warn",
  ], force: :cascade

  create_enum :feedbacks_categories, [
    "need",
    "reminder",
    "solicitation",
  ], force: :cascade

  create_enum :match_status, [
    "quo",
    "taking_care",
    "done",
    "done_no_help",
    "done_not_reachable",
    "not_for_me",
  ], force: :cascade

  create_enum :need_status, [
    "diagnosis_not_complete",
    "quo",
    "taking_care",
    "done",
    "not_for_me",
    "done_no_help",
    "done_not_reachable",
  ], force: :cascade

  create_table "antennes", force: :cascade do |t|
    t.string "name"
    t.bigint "institution_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_antennes_on_deleted_at"
    t.index ["institution_id"], name: "index_antennes_on_institution_id"
    t.index ["name", "institution_id"], name: "index_antennes_on_name_and_institution_id", unique: true
    t.index ["updated_at"], name: "index_antennes_on_updated_at"
  end

  create_table "antennes_communes", id: false, force: :cascade do |t|
    t.bigint "antenne_id", null: false
    t.bigint "commune_id", null: false
    t.index ["antenne_id"], name: "index_antennes_communes_on_antenne_id"
    t.index ["commune_id"], name: "index_antennes_communes_on_commune_id"
  end

  create_table "badges", force: :cascade do |t|
    t.string "title", null: false
    t.string "color", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "badges_solicitations", id: false, force: :cascade do |t|
    t.bigint "badge_id", null: false
    t.bigint "solicitation_id", null: false
  end

  create_table "communes", force: :cascade do |t|
    t.string "insee_code"
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
    t.date "date_de_creation"
    t.index ["siren"], name: "index_companies_on_siren", unique: true, where: "((siren)::text <> NULL::text)"
  end

  create_table "company_satisfactions", force: :cascade do |t|
    t.boolean "contacted_by_expert"
    t.boolean "useful_exchange"
    t.text "comment"
    t.bigint "need_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["need_id"], name: "index_company_satisfactions_on_need_id"
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
    t.bigint "advisor_id"
    t.bigint "visitee_id"
    t.bigint "facility_id", null: false
    t.date "happened_on"
    t.bigint "solicitation_id"
    t.boolean "newsletter_subscription_email_sent", default: false, null: false
    t.datetime "completed_at"
    t.index ["advisor_id"], name: "index_diagnoses_on_advisor_id"
    t.index ["archived_at"], name: "index_diagnoses_on_archived_at"
    t.index ["facility_id"], name: "index_diagnoses_on_facility_id"
    t.index ["solicitation_id"], name: "index_diagnoses_on_solicitation_id"
    t.index ["visitee_id"], name: "index_diagnoses_on_visitee_id"
  end

  create_table "experts", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.bigint "antenne_id", null: false
    t.boolean "is_global_zone", default: false
    t.text "reminders_notes"
    t.datetime "deleted_at"
    t.jsonb "flags", default: {}
    t.index ["antenne_id"], name: "index_experts_on_antenne_id"
    t.index ["deleted_at"], name: "index_experts_on_deleted_at"
    t.index ["email"], name: "index_experts_on_email"
  end

  create_table "experts_subjects", force: :cascade do |t|
    t.string "intervention_criteria"
    t.bigint "expert_id"
    t.bigint "institution_subject_id"
    t.index ["expert_id", "institution_subject_id"], name: "index_experts_subjects_on_expert_id_and_institution_subject_id", unique: true
    t.index ["expert_id"], name: "index_experts_subjects_on_expert_id"
    t.index ["institution_subject_id"], name: "index_experts_subjects_on_institution_subject_id"
  end

  create_table "experts_users", id: false, force: :cascade do |t|
    t.bigint "expert_id", null: false
    t.bigint "user_id", null: false
    t.index ["expert_id", "user_id"], name: "index_experts_users_on_expert_id_and_user_id", unique: true
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
    t.string "naf_libelle"
    t.string "naf_code_a10"
    t.index ["commune_id"], name: "index_facilities_on_commune_id"
    t.index ["company_id"], name: "index_facilities_on_company_id"
    t.index ["siret"], name: "index_facilities_on_siret", unique: true, where: "((siret)::text <> NULL::text)"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "feedbackable_type"
    t.bigint "feedbackable_id"
    t.enum "category", null: false, enum_name: "feedbacks_categories"
    t.index ["category"], name: "index_feedbacks_on_category"
    t.index ["feedbackable_type", "feedbackable_id"], name: "index_feedbacks_on_feedbackable_type_and_feedbackable_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.boolean "show_on_list", default: false
    t.integer "logo_sort_order"
    t.datetime "deleted_at"
    t.integer "code_region"
    t.index ["code_region"], name: "index_institutions_on_code_region"
    t.index ["deleted_at"], name: "index_institutions_on_deleted_at"
    t.index ["name"], name: "index_institutions_on_name", unique: true
    t.index ["slug"], name: "index_institutions_on_slug", unique: true
    t.index ["updated_at"], name: "index_institutions_on_updated_at"
  end

  create_table "institutions_subjects", force: :cascade do |t|
    t.string "description"
    t.bigint "institution_id"
    t.bigint "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "index_institutions_subjects_on_institution_id"
    t.index ["subject_id", "institution_id", "description"], name: "unique_institution_subject_in_institution", unique: true
    t.index ["subject_id"], name: "index_institutions_subjects_on_subject_id"
    t.index ["updated_at"], name: "index_institutions_subjects_on_updated_at"
  end

  create_table "landing_options", force: :cascade do |t|
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

  create_table "landings", force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "home_title", default: ""
    t.text "home_description", default: ""
    t.integer "home_sort_order"
    t.bigint "institution_id"
    t.string "meta_title"
    t.string "meta_description"
    t.string "title"
    t.string "subtitle"
    t.string "logos"
    t.string "custom_css"
    t.string "message_under_landing_topics"
    t.string "partner_url"
    t.boolean "emphasis", default: false
    t.string "main_logo"
    t.index ["institution_id"], name: "index_landings_on_institution_id"
    t.index ["slug"], name: "index_landings_on_slug", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "taken_care_of_at"
    t.datetime "closed_at"
    t.bigint "expert_id"
    t.bigint "subject_id"
    t.enum "status", default: "quo", null: false, enum_name: "match_status"
    t.datetime "archived_at"
    t.index ["expert_id", "need_id"], name: "index_matches_on_expert_id_and_need_id", unique: true, where: "(expert_id <> NULL::bigint)"
    t.index ["expert_id"], name: "index_matches_on_expert_id"
    t.index ["need_id"], name: "index_matches_on_need_id"
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
    t.boolean "satisfaction_email_sent", default: false, null: false
    t.enum "status", default: "diagnosis_not_complete", null: false, enum_name: "need_status"
    t.index ["archived_at"], name: "index_needs_on_archived_at"
    t.index ["diagnosis_id"], name: "index_needs_on_diagnosis_id"
    t.index ["status"], name: "index_needs_on_status"
    t.index ["subject_id", "diagnosis_id"], name: "index_needs_on_subject_id_and_diagnosis_id", unique: true
    t.index ["subject_id"], name: "index_needs_on_subject_id"
  end

  create_table "reminders_actions", force: :cascade do |t|
    t.bigint "need_id", null: false
    t.enum "category", null: false, enum_name: "actions_categories"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_reminders_actions_on_category"
    t.index ["need_id", "category"], name: "index_reminders_actions_on_need_id_and_category", unique: true
    t.index ["need_id"], name: "index_reminders_actions_on_need_id"
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

  create_table "solicitations", force: :cascade do |t|
    t.string "description"
    t.string "email"
    t.string "phone_number"
    t.jsonb "form_info", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "siret"
    t.integer "status", default: 0
    t.string "full_name"
    t.string "landing_slug", null: false
    t.string "landing_options_slugs", array: true
    t.jsonb "prepare_diagnosis_errors_details", default: {}
    t.string "requested_help_amount"
    t.string "location"
    t.bigint "institution_id"
    t.integer "code_region"
    t.boolean "created_in_deployed_region", default: false
    t.index ["code_region"], name: "index_solicitations_on_code_region"
    t.index ["email"], name: "index_solicitations_on_email"
    t.index ["institution_id"], name: "index_solicitations_on_institution_id"
    t.index ["landing_slug"], name: "index_solicitations_on_landing_slug"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "theme_id", null: false
    t.integer "interview_sort_order"
    t.datetime "archived_at"
    t.boolean "is_support", default: false
    t.string "slug", null: false
    t.index ["archived_at"], name: "index_subjects_on_archived_at"
    t.index ["interview_sort_order"], name: "index_subjects_on_interview_sort_order"
    t.index ["label"], name: "index_subjects_on_label", unique: true
    t.index ["slug"], name: "index_subjects_on_slug", unique: true
    t.index ["theme_id"], name: "index_subjects_on_theme_id"
  end

  create_table "territories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bassin_emploi", default: false, null: false
    t.bigint "support_contact_id"
    t.integer "code_region"
    t.datetime "deployed_at"
    t.index ["code_region"], name: "index_territories_on_code_region"
    t.index ["support_contact_id"], name: "index_territories_on_support_contact_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "interview_sort_order"
    t.index ["interview_sort_order"], name: "index_themes_on_interview_sort_order"
    t.index ["label"], name: "index_themes_on_label", unique: true
    t.index ["updated_at"], name: "index_themes_on_updated_at"
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
    t.bigint "antenne_id", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.bigint "inviter_id"
    t.integer "invitations_count", default: 0
    t.datetime "deleted_at"
    t.jsonb "flags", default: {}
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
  add_foreign_key "company_satisfactions", "needs"
  add_foreign_key "contacts", "companies"
  add_foreign_key "diagnoses", "contacts", column: "visitee_id"
  add_foreign_key "diagnoses", "facilities"
  add_foreign_key "diagnoses", "solicitations"
  add_foreign_key "diagnoses", "users", column: "advisor_id"
  add_foreign_key "experts", "antennes"
  add_foreign_key "experts_subjects", "experts"
  add_foreign_key "experts_subjects", "institutions_subjects"
  add_foreign_key "experts_users", "experts"
  add_foreign_key "experts_users", "users"
  add_foreign_key "facilities", "communes"
  add_foreign_key "facilities", "companies"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "institutions_subjects", "institutions"
  add_foreign_key "institutions_subjects", "subjects"
  add_foreign_key "landing_options", "landings"
  add_foreign_key "landing_topics", "landings"
  add_foreign_key "landings", "institutions"
  add_foreign_key "matches", "experts"
  add_foreign_key "matches", "needs"
  add_foreign_key "matches", "subjects"
  add_foreign_key "needs", "diagnoses"
  add_foreign_key "needs", "subjects"
  add_foreign_key "reminders_actions", "needs"
  add_foreign_key "searches", "users"
  add_foreign_key "solicitations", "institutions"
  add_foreign_key "subjects", "themes"
  add_foreign_key "users", "antennes"
  add_foreign_key "users", "users", column: "inviter_id"
end
