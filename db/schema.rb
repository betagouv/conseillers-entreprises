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

ActiveRecord::Schema[8.1].define(version: 2026_03_10_152231) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "activity_reports_categories", ["matches", "stats", "cooperation", "solicitations"]
  create_enum "feedbacks_categories", ["need", "need_reminder", "solicitation", "expert_reminder"]
  create_enum "landing_subject_fields_mode", ["siret", "location"]
  create_enum "match_status", ["quo", "taking_care", "done", "done_no_help", "done_not_reachable", "not_for_me"]
  create_enum "need_status", ["diagnosis_not_complete", "quo", "taking_care", "done", "not_for_me", "done_no_help", "done_not_reachable"]
  create_enum "territorial_level", ["local", "regional", "national"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_reports", force: :cascade do |t|
    t.enum "category", enum_type: "activity_reports_categories"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "reportable_id", null: false
    t.string "reportable_type", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_activity_reports_on_category"
    t.index ["reportable_id"], name: "index_activity_reports_reportable_id"
    t.index ["reportable_type", "reportable_id"], name: "index_activity_reports_on_reportable"
  end

  create_table "antennes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "imported_at"
    t.bigint "institution_id", null: false
    t.string "name", null: false
    t.bigint "parent_antenne_id"
    t.enum "territorial_level", default: "local", null: false, enum_type: "territorial_level"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_antennes_on_deleted_at"
    t.index ["institution_id"], name: "index_antennes_on_institution_id"
    t.index ["name", "deleted_at", "institution_id"], name: "index_antennes_on_name_and_deleted_at_and_institution_id"
    t.index ["parent_antenne_id"], name: "index_antennes_on_parent_antenne_id"
    t.index ["territorial_level"], name: "index_antennes_on_territorial_level"
    t.index ["updated_at"], name: "index_antennes_on_updated_at"
  end

  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "institution_id", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_until"
    t.index ["institution_id"], name: "index_api_keys_institution_id", unique: true
    t.index ["institution_id"], name: "index_api_keys_on_institution_id"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "badge_badgeables", force: :cascade do |t|
    t.bigint "badge_id", null: false
    t.bigint "badgeable_id", null: false
    t.string "badgeable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_badgeables_on_badge_id"
    t.index ["badgeable_id", "badgeable_type"], name: "index_badge_badgeables_badgeable_id_badgeable_type"
  end

  create_table "badges", force: :cascade do |t|
    t.integer "category", null: false
    t.string "color", default: "#000000", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title", "category"], name: "index_badges_on_title_and_category", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_institutions", id: false, force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "institution_id", null: false
    t.index ["category_id"], name: "index_categories_institutions_on_category_id"
    t.index ["institution_id"], name: "index_categories_institutions_on_institution_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "code_effectif"
    t.datetime "created_at", precision: nil, null: false
    t.date "date_de_creation"
    t.float "effectif"
    t.string "forme_exercice"
    t.string "legal_form_code"
    t.string "name", null: false
    t.string "siren"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["siren"], name: "index_companies_on_siren", unique: true, where: "((siren)::text <> NULL::text)"
  end

  create_table "company_satisfactions", force: :cascade do |t|
    t.text "comment"
    t.boolean "contacted_by_expert", null: false
    t.datetime "created_at", null: false
    t.bigint "need_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "useful_exchange", null: false
    t.index ["need_id"], name: "index_company_satisfactions_on_need_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "full_name", null: false
    t.string "phone_number"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
    t.index ["email"], name: "index_contacts_on_email"
  end

  create_table "cooperation_themes", force: :cascade do |t|
    t.bigint "cooperation_id", null: false
    t.datetime "created_at", null: false
    t.bigint "theme_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cooperation_id"], name: "index_cooperation_themes_on_cooperation_id"
    t.index ["theme_id"], name: "index_cooperation_themes_on_theme_id"
  end

  create_table "cooperations", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.boolean "display_matches_stats", default: false, null: false
    t.boolean "display_pde_partnership_mention", default: false, null: false
    t.boolean "display_url", default: false, null: false
    t.boolean "external", default: false, null: false
    t.bigint "institution_id", null: false
    t.string "mtm_campaign"
    t.string "name", null: false
    t.string "root_url"
    t.datetime "updated_at", null: false
    t.boolean "wants_solicitations_export", default: false, null: false
    t.index ["institution_id"], name: "index_cooperations_on_institution_id"
    t.index ["name"], name: "index_cooperations_on_name", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diagnoses", force: :cascade do |t|
    t.bigint "advisor_id"
    t.datetime "completed_at", precision: nil
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "facility_id", null: false
    t.date "happened_on"
    t.boolean "retention_email_sent", default: false, null: false
    t.bigint "solicitation_id"
    t.integer "step", default: 1
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "visitee_id"
    t.index ["advisor_id"], name: "index_diagnoses_on_advisor_id"
    t.index ["facility_id", "step"], name: "index_diagnoses_on_facility_id_and_step"
    t.index ["facility_id"], name: "index_diagnoses_on_facility_id"
    t.index ["solicitation_id"], name: "index_diagnoses_on_solicitation_id"
    t.index ["step", "created_at"], name: "index_diagnoses_on_step_and_created_at"
    t.index ["visitee_id"], name: "index_diagnoses_on_visitee_id"
  end

  create_table "email_retentions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_subject", null: false
    t.text "first_paragraph", null: false
    t.bigint "first_subject_id", null: false
    t.string "first_subject_label", null: false
    t.bigint "second_subject_id", null: false
    t.string "second_subject_label", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.integer "waiting_time", null: false
    t.index ["first_subject_id"], name: "index_email_retentions_on_first_subject_id"
    t.index ["second_subject_id"], name: "index_email_retentions_on_second_subject_id"
    t.index ["subject_id"], name: "index_email_retentions_on_subject_id", unique: true
  end

  create_table "experts", force: :cascade do |t|
    t.bigint "antenne_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "email"
    t.string "full_name", null: false
    t.boolean "is_global_zone", default: false, null: false
    t.string "job"
    t.string "phone_number"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["antenne_id"], name: "index_experts_on_antenne_id"
    t.index ["deleted_at"], name: "index_experts_on_deleted_at"
    t.index ["email"], name: "index_experts_on_email"
  end

  create_table "experts_subjects", force: :cascade do |t|
    t.bigint "expert_id", null: false
    t.bigint "institution_subject_id", null: false
    t.string "intervention_criteria"
    t.index ["expert_id", "institution_subject_id"], name: "index_experts_subjects_on_expert_id_and_institution_subject_id", unique: true
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
    t.string "code_effectif"
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.float "effectif"
    t.string "insee_code", null: false
    t.string "naf_code"
    t.string "naf_code_a10"
    t.string "naf_libelle"
    t.string "nafa_codes", default: [], array: true
    t.string "nature_activites", default: [], array: true
    t.bigint "opco_id"
    t.string "readable_locality"
    t.string "siret"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_facilities_on_company_id"
    t.index ["opco_id"], name: "index_facilities_on_opco_id"
    t.index ["siret"], name: "index_facilities_on_siret", unique: true, where: "((siret)::text <> NULL::text)"
    t.check_constraint "insee_code::text ~ '^[0-9AB]{5}$'::text", name: "check_facilities_insee_code_format"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.enum "category", null: false, enum_type: "feedbacks_categories"
    t.datetime "created_at", precision: nil, null: false
    t.text "description", null: false
    t.bigint "feedbackable_id", null: false
    t.string "feedbackable_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_feedbacks_on_category"
    t.index ["feedbackable_type", "feedbackable_id"], name: "index_feedbacks_on_feedbackable_type_and_feedbackable_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.integer "code_region"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.boolean "display_logo_in_partner_list", default: true, null: false
    t.boolean "display_logo_on_home_page", default: true, null: false
    t.string "france_competence_code"
    t.string "name", null: false
    t.boolean "show_on_list", default: false, null: false
    t.text "siren"
    t.string "slug", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code_region"], name: "index_institutions_on_code_region"
    t.index ["deleted_at"], name: "index_institutions_on_deleted_at"
    t.index ["name"], name: "index_institutions_on_name", unique: true
    t.index ["slug"], name: "index_institutions_on_slug", unique: true
    t.index ["updated_at"], name: "index_institutions_on_updated_at"
  end

  create_table "institutions_subjects", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.bigint "institution_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["institution_id"], name: "index_institutions_subjects_on_institution_id"
    t.index ["subject_id", "institution_id", "description"], name: "unique_institution_subject_in_institution", unique: true
    t.index ["updated_at"], name: "index_institutions_subjects_on_updated_at"
  end

  create_table "landing_joint_themes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "landing_id", null: false
    t.bigint "landing_theme_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["landing_id"], name: "index_landing_joint_themes_on_landing_id"
    t.index ["landing_theme_id"], name: "index_landing_joint_themes_on_landing_theme_id"
  end

  create_table "landing_subjects", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.text "description"
    t.text "description_explanation"
    t.text "description_prefill"
    t.enum "fields_mode", null: false, enum_type: "landing_subject_fields_mode"
    t.text "form_description"
    t.string "form_title"
    t.bigint "landing_theme_id", null: false
    t.string "meta_description"
    t.string "meta_title"
    t.integer "position"
    t.string "slug"
    t.bigint "subject_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_landing_subjects_on_archived_at"
    t.index ["landing_theme_id"], name: "index_landing_subjects_on_landing_theme_id"
    t.index ["slug", "landing_theme_id"], name: "index_landing_subjects_on_slug_and_landing_theme_id", unique: true
    t.index ["subject_id"], name: "index_landing_subjects_on_subject_id"
  end

  create_table "landing_themes", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.text "description"
    t.string "meta_description"
    t.string "meta_title"
    t.string "page_title"
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_landing_themes_on_archived_at"
    t.index ["slug"], name: "index_landing_themes_on_slug", unique: true
  end

  create_table "landings", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.bigint "cooperation_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "custom_css"
    t.boolean "emphasis", default: false, null: false
    t.text "home_description", default: ""
    t.integer "iframe_category", default: 1
    t.text "information_banner"
    t.integer "integration", default: 0
    t.integer "layout", default: 1
    t.string "meta_description"
    t.string "meta_title"
    t.datetime "paused_at"
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url_path"
    t.index ["archived_at"], name: "index_landings_on_archived_at"
    t.index ["cooperation_id"], name: "index_landings_on_cooperation_id"
    t.index ["slug"], name: "index_landings_on_slug", unique: true
  end

  create_table "logos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.bigint "logoable_id", null: false
    t.string "logoable_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["logoable_type", "logoable_id"], name: "index_logos_on_logoable"
  end

  create_table "match_filters", force: :cascade do |t|
    t.string "accepted_legal_forms", array: true
    t.string "accepted_naf_codes", array: true
    t.datetime "created_at", null: false
    t.integer "effectif_max"
    t.integer "effectif_min"
    t.string "excluded_legal_forms", array: true
    t.string "excluded_naf_codes", array: true
    t.bigint "filtrable_element_id", null: false
    t.string "filtrable_element_type", null: false
    t.integer "max_years_of_existence"
    t.integer "min_years_of_existence"
    t.datetime "updated_at", null: false
    t.index ["filtrable_element_type", "filtrable_element_id"], name: "index_match_filters_on_filtrable_element"
  end

  create_table "match_filters_subjects", id: false, force: :cascade do |t|
    t.bigint "match_filter_id"
    t.bigint "subject_id"
    t.index ["match_filter_id"], name: "index_match_filters_subjects_on_match_filter_id"
    t.index ["subject_id"], name: "index_match_filters_subjects_on_subject_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "closed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.bigint "expert_id", null: false
    t.bigint "need_id", null: false
    t.datetime "sent_at", precision: nil
    t.enum "status", default: "quo", null: false, enum_type: "match_status"
    t.bigint "subject_id", null: false
    t.datetime "taken_care_of_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["expert_id", "need_id"], name: "index_matches_on_expert_id_and_need_id", unique: true, where: "(expert_id <> NULL::bigint)"
    t.index ["expert_id"], name: "index_matches_on_expert_id"
    t.index ["need_id"], name: "index_matches_on_need_id"
    t.index ["status"], name: "index_matches_on_status"
    t.index ["subject_id"], name: "index_matches_on_subject_id"
  end

  create_table "needs", force: :cascade do |t|
    t.boolean "abandoned_email_sent", default: false, null: false
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "diagnosis_id", null: false
    t.integer "matches_count"
    t.datetime "retention_sent_at", precision: nil
    t.boolean "satisfaction_email_sent", default: false, null: false
    t.datetime "starred_at", precision: nil
    t.enum "status", default: "diagnosis_not_complete", null: false, enum_type: "need_status"
    t.bigint "subject_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["diagnosis_id"], name: "index_needs_on_diagnosis_id"
    t.index ["status"], name: "index_needs_on_status"
    t.index ["subject_id", "diagnosis_id"], name: "index_needs_on_subject_id_and_diagnosis_id", unique: true
  end

  create_table "profil_pictures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_profil_pictures_on_user_id", unique: true
  end

  create_table "reminders_actions", force: :cascade do |t|
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.bigint "need_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "need_id"], name: "index_reminders_actions_category_need_id", unique: true
    t.index ["need_id", "category"], name: "index_reminders_actions_on_need_id_and_category", unique: true
  end

  create_table "reminders_registers", force: :cascade do |t|
    t.integer "basket"
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "expert_id", null: false
    t.integer "expired_count", default: 0
    t.boolean "processed", default: false, null: false
    t.integer "run_number", null: false
    t.datetime "updated_at", null: false
    t.index ["expert_id"], name: "index_reminders_registers_on_expert_id"
    t.index ["run_number", "expert_id"], name: "index_reminders_registers_on_run_number_and_expert_id", unique: true
  end

  create_table "shared_satisfactions", force: :cascade do |t|
    t.bigint "company_satisfaction_id", null: false
    t.datetime "created_at", null: false
    t.bigint "expert_id", null: false
    t.datetime "seen_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_satisfaction_id"], name: "index_shared_satisfactions_on_company_satisfaction_id"
    t.index ["expert_id"], name: "index_shared_satisfactions_on_expert_id"
    t.index ["user_id", "company_satisfaction_id", "expert_id"], name: "shared_satisfactions_references_index", unique: true
  end

  create_table "solicitations", force: :cascade do |t|
    t.integer "code_region"
    t.datetime "completed_at", precision: nil
    t.bigint "cooperation_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "email"
    t.jsonb "form_info", default: {}
    t.string "full_name"
    t.string "insee_code"
    t.bigint "landing_id"
    t.string "landing_slug"
    t.bigint "landing_subject_id"
    t.string "location"
    t.string "phone_number"
    t.jsonb "prepare_diagnosis_errors_details", default: {}
    t.string "provenance_detail"
    t.string "requested_help_amount"
    t.string "siret"
    t.integer "status", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "uuid"
    t.index ["code_region"], name: "index_solicitations_on_code_region"
    t.index ["cooperation_id"], name: "index_solicitations_on_cooperation_id"
    t.index ["email"], name: "index_solicitations_on_email"
    t.index ["landing_id"], name: "index_solicitations_on_landing_id"
    t.index ["landing_slug"], name: "index_solicitations_on_landing_slug"
    t.index ["landing_subject_id"], name: "index_solicitations_on_landing_subject_id"
    t.index ["status", "completed_at"], name: "index_solicitations_on_status_and_completed_at"
    t.index ["status"], name: "index_solicitations_on_status"
    t.index ["uuid"], name: "index_solicitations_on_uuid"
    t.check_constraint "insee_code::text ~ '^[0-9AB]{5}$'::text", name: "check_solicitations_insee_code_format"
  end

  create_table "spams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_spams_on_email", unique: true
  end

  create_table "subject_answer_groupings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "institution_id", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "index_subject_answer_groupings_on_institution_id"
  end

  create_table "subject_answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filter_value"
    t.bigint "subject_answer_grouping_id"
    t.bigint "subject_question_id", null: false
    t.bigint "subject_questionable_id"
    t.string "subject_questionable_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["subject_answer_grouping_id"], name: "index_subject_answers_on_subject_answer_grouping_id"
    t.index ["subject_question_id"], name: "index_subject_answers_on_subject_question_id"
    t.index ["subject_questionable_id", "subject_questionable_type", "subject_question_id"], name: "institution_filtrable_additional_subject_question_index", unique: true
    t.index ["subject_questionable_type", "subject_questionable_id"], name: "index_institution_filters_on_institution_filtrable"
    t.index ["type"], name: "index_subject_answers_on_type"
  end

  create_table "subject_questions", force: :cascade do |t|
    t.string "key", null: false
    t.integer "position"
    t.bigint "subject_id", null: false
    t.index ["subject_id", "key"], name: "additional_subject_question_subject_key_index", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.integer "interview_sort_order"
    t.boolean "is_support", default: false, null: false
    t.string "label", null: false
    t.string "slug", null: false
    t.bigint "theme_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["archived_at"], name: "index_subjects_on_archived_at"
    t.index ["interview_sort_order"], name: "index_subjects_on_interview_sort_order"
    t.index ["label"], name: "index_subjects_on_label", unique: true
    t.index ["slug"], name: "index_subjects_on_slug", unique: true
    t.index ["theme_id"], name: "index_subjects_on_theme_id"
  end

  create_table "territorial_zones", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "regions_codes", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "zone_type", null: false
    t.bigint "zoneable_id", null: false
    t.string "zoneable_type", null: false
    t.index ["code", "zone_type", "zoneable_type", "zoneable_id"], name: "idx_on_code_zone_type_zoneable_type_zoneable_id_0c5f85b4e4", unique: true
    t.index ["zoneable_type", "zoneable_id"], name: "index_territorial_zones_on_zoneable"
  end

  create_table "themes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "interview_sort_order"
    t.string "label", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["interview_sort_order"], name: "index_themes_on_interview_sort_order"
    t.index ["label"], name: "index_themes_on_label", unique: true
    t.index ["updated_at"], name: "index_themes_on_updated_at"
  end

  create_table "user_rights", force: :cascade do |t|
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.bigint "rightable_element_id"
    t.string "rightable_element_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["rightable_element_type", "rightable_element_id"], name: "index_user_rights_on_rightable_element"
    t.index ["user_id", "category", "rightable_element_id", "rightable_element_type"], name: "unique_category_rightable_element_index", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "absence_end_at"
    t.datetime "absence_start_at"
    t.bigint "antenne_id", null: false
    t.jsonb "app_info", default: {}
    t.datetime "cgu_accepted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.datetime "deleted_at", precision: nil
    t.datetime "demo_invited_at"
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.datetime "imported_at"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "inviter_id"
    t.string "job", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "phone_number"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["antenne_id"], name: "index_users_on_antenne_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email)::text <> NULL::text)"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "antennes", "antennes", column: "parent_antenne_id"
  add_foreign_key "antennes", "institutions"
  add_foreign_key "api_keys", "institutions"
  add_foreign_key "badge_badgeables", "badges"
  add_foreign_key "company_satisfactions", "needs"
  add_foreign_key "contacts", "companies"
  add_foreign_key "cooperation_themes", "cooperations"
  add_foreign_key "cooperation_themes", "themes"
  add_foreign_key "cooperations", "institutions"
  add_foreign_key "diagnoses", "contacts", column: "visitee_id"
  add_foreign_key "diagnoses", "facilities"
  add_foreign_key "diagnoses", "solicitations"
  add_foreign_key "diagnoses", "users", column: "advisor_id"
  add_foreign_key "email_retentions", "subjects"
  add_foreign_key "email_retentions", "subjects", column: "first_subject_id"
  add_foreign_key "email_retentions", "subjects", column: "second_subject_id"
  add_foreign_key "experts", "antennes"
  add_foreign_key "experts_subjects", "experts"
  add_foreign_key "experts_subjects", "institutions_subjects"
  add_foreign_key "experts_users", "experts"
  add_foreign_key "experts_users", "users"
  add_foreign_key "facilities", "companies"
  add_foreign_key "facilities", "institutions", column: "opco_id"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "institutions_subjects", "institutions"
  add_foreign_key "institutions_subjects", "subjects"
  add_foreign_key "landing_joint_themes", "landing_themes"
  add_foreign_key "landing_joint_themes", "landings"
  add_foreign_key "landing_subjects", "landing_themes"
  add_foreign_key "landing_subjects", "subjects"
  add_foreign_key "landings", "cooperations"
  add_foreign_key "matches", "experts"
  add_foreign_key "matches", "needs"
  add_foreign_key "matches", "subjects"
  add_foreign_key "needs", "diagnoses"
  add_foreign_key "needs", "subjects"
  add_foreign_key "profil_pictures", "users"
  add_foreign_key "reminders_actions", "needs"
  add_foreign_key "reminders_registers", "experts"
  add_foreign_key "shared_satisfactions", "company_satisfactions"
  add_foreign_key "shared_satisfactions", "experts"
  add_foreign_key "shared_satisfactions", "users"
  add_foreign_key "solicitations", "cooperations"
  add_foreign_key "solicitations", "landing_subjects"
  add_foreign_key "solicitations", "landings"
  add_foreign_key "subject_answer_groupings", "institutions"
  add_foreign_key "subject_answers", "subject_questions"
  add_foreign_key "subject_questions", "subjects"
  add_foreign_key "subjects", "themes"
  add_foreign_key "user_rights", "users"
  add_foreign_key "users", "antennes"
  add_foreign_key "users", "users", column: "inviter_id"
end
