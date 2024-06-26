class InitSchema < ActiveRecord::Migration[7.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_enum :feedbacks_categories, [
      "need",
      "need_reminder",
      "solicitation",
      "expert_reminder",
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
    create_enum :quarterly_reports_categories, [
      "matches",
      "stats",
    ], force: :cascade
    create_enum :territorial_level, [
      "local",
      "regional",
      "national",
    ], force: :cascade
    create_table "active_storage_attachments" do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.string "service_name", null: false
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.datetime "created_at", precision: nil, null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "active_storage_variant_records" do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    end
    create_table "additional_subject_questions" do |t|
      t.bigint "subject_id"
      t.string "key"
      t.integer "position"
      t.index ["subject_id"], name: "index_additional_subject_questions_on_subject_id"
    end
    create_table "antennes", id: :serial do |t|
      t.string "name"
      t.bigint "institution_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.datetime "deleted_at", precision: nil
      t.enum "territorial_level", default: "local", null: false, enum_type: "territorial_level"
      t.index ["deleted_at"], name: "index_antennes_on_deleted_at"
      t.index ["institution_id"], name: "index_antennes_on_institution_id"
      t.index ["name", "deleted_at", "institution_id"], name: "index_antennes_on_name_and_deleted_at_and_institution_id"
      t.index ["territorial_level"], name: "index_antennes_on_territorial_level"
      t.index ["updated_at"], name: "index_antennes_on_updated_at"
    end
    create_table "antennes_communes", id: false do |t|
      t.bigint "antenne_id", null: false
      t.bigint "commune_id", null: false
      t.index ["antenne_id"], name: "index_antennes_communes_on_antenne_id"
      t.index ["commune_id"], name: "index_antennes_communes_on_commune_id"
    end
    create_table "badges", id: :serial do |t|
      t.string "title", null: false
      t.string "color", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
    create_table "badges_solicitations", id: false do |t|
      t.bigint "badge_id", null: false
      t.bigint "solicitation_id", null: false
    end
    create_table "categories", id: :serial do |t|
      t.string "label", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
    create_table "categories_institutions", id: false do |t|
      t.bigint "institution_id", null: false
      t.bigint "category_id", null: false
      t.index ["category_id"], name: "index_categories_institutions_on_category_id"
      t.index ["institution_id"], name: "index_categories_institutions_on_institution_id"
    end
    create_table "communes", id: :serial do |t|
      t.string "insee_code"
      t.index ["insee_code"], name: "index_communes_on_insee_code", unique: true
    end
    create_table "communes_experts", id: false do |t|
      t.bigint "commune_id", null: false
      t.bigint "expert_id", null: false
      t.index ["commune_id"], name: "index_communes_experts_on_commune_id"
      t.index ["expert_id"], name: "index_communes_experts_on_expert_id"
    end
    create_table "communes_territories", id: :serial do |t|
      t.bigint "territory_id", null: false
      t.bigint "commune_id", null: false
      t.index ["commune_id"], name: "index_communes_territories_on_commune_id"
      t.index ["territory_id"], name: "index_communes_territories_on_territory_id"
    end
    create_table "companies", id: :serial do |t|
      t.string "name"
      t.string "siren"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "legal_form_code"
      t.string "code_effectif"
      t.date "date_de_creation"
      t.boolean "inscrit_rcs"
      t.boolean "inscrit_rm"
      t.float "effectif"
      t.index ["siren"], name: "index_companies_on_siren", unique: true, where: "((siren)::text <> NULL::text)"
    end
    create_table "company_satisfactions", id: :serial do |t|
      t.boolean "contacted_by_expert"
      t.boolean "useful_exchange"
      t.text "comment"
      t.bigint "need_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["need_id"], name: "index_company_satisfactions_on_need_id"
    end
    create_table "contacts", id: :serial do |t|
      t.string "email"
      t.string "phone_number"
      t.bigint "company_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "full_name"
      t.index ["company_id"], name: "index_contacts_on_company_id"
    end
    create_table "delayed_jobs", id: :serial do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at", precision: nil
      t.datetime "locked_at", precision: nil
      t.datetime "failed_at", precision: nil
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end
    create_table "diagnoses", id: :serial do |t|
      t.text "content"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "step", default: 1
      t.datetime "archived_at", precision: nil
      t.bigint "advisor_id"
      t.bigint "visitee_id"
      t.bigint "facility_id", null: false
      t.date "happened_on"
      t.bigint "solicitation_id"
      t.datetime "completed_at", precision: nil
      t.boolean "retention_email_sent", default: false
      t.index ["advisor_id"], name: "index_diagnoses_on_advisor_id"
      t.index ["archived_at"], name: "index_diagnoses_on_archived_at"
      t.index ["facility_id"], name: "index_diagnoses_on_facility_id"
      t.index ["solicitation_id"], name: "index_diagnoses_on_solicitation_id"
      t.index ["visitee_id"], name: "index_diagnoses_on_visitee_id"
    end
    create_table "experts", id: :serial do |t|
      t.string "email"
      t.string "phone_number"
      t.string "job"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "full_name"
      t.bigint "antenne_id", null: false
      t.boolean "is_global_zone", default: false
      t.text "reminders_notes"
      t.datetime "deleted_at", precision: nil
      t.index ["antenne_id"], name: "index_experts_on_antenne_id"
      t.index ["deleted_at"], name: "index_experts_on_deleted_at"
      t.index ["email"], name: "index_experts_on_email"
    end
    create_table "experts_subjects", id: :serial do |t|
      t.string "intervention_criteria"
      t.bigint "expert_id"
      t.bigint "institution_subject_id"
      t.index ["expert_id", "institution_subject_id"], name: "index_experts_subjects_on_expert_id_and_institution_subject_id", unique: true
      t.index ["expert_id"], name: "index_experts_subjects_on_expert_id"
      t.index ["institution_subject_id"], name: "index_experts_subjects_on_institution_subject_id"
    end
    create_table "experts_users", id: false do |t|
      t.bigint "expert_id", null: false
      t.bigint "user_id", null: false
      t.index ["expert_id", "user_id"], name: "index_experts_users_on_expert_id_and_user_id", unique: true
      t.index ["expert_id"], name: "index_experts_users_on_expert_id"
      t.index ["user_id"], name: "index_experts_users_on_user_id"
    end
    create_table "facilities", id: :serial do |t|
      t.bigint "company_id", null: false
      t.string "siret"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "naf_code"
      t.string "readable_locality"
      t.bigint "commune_id", null: false
      t.string "code_effectif"
      t.string "naf_libelle"
      t.string "naf_code_a10"
      t.bigint "opco_id"
      t.float "effectif"
      t.index ["commune_id"], name: "index_facilities_on_commune_id"
      t.index ["company_id"], name: "index_facilities_on_company_id"
      t.index ["opco_id"], name: "index_facilities_on_opco_id"
      t.index ["siret"], name: "index_facilities_on_siret", unique: true, where: "((siret)::text <> NULL::text)"
    end
    create_table "feedbacks", id: :serial do |t|
      t.text "description"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "user_id"
      t.string "feedbackable_type"
      t.bigint "feedbackable_id"
      t.enum "category", null: false, enum_type: "feedbacks_categories"
      t.index ["category"], name: "index_feedbacks_on_category"
      t.index ["feedbackable_type", "feedbackable_id"], name: "index_feedbacks_on_feedbackable_type_and_feedbackable_id"
      t.index ["user_id"], name: "index_feedbacks_on_user_id"
    end
    create_table "institution_filters" do |t|
      t.bigint "additional_subject_question_id"
      t.string "institution_filtrable_type"
      t.bigint "institution_filtrable_id"
      t.boolean "filter_value"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["additional_subject_question_id"], name: "index_institution_filters_on_additional_subject_question_id"
      t.index ["institution_filtrable_id", "institution_filtrable_type", "additional_subject_question_id"], name: "institution_filtrable_additional_subject_question_index", unique: true
      t.index ["institution_filtrable_type", "institution_filtrable_id"], name: "index_institution_filters_on_institution_filtrable"
    end
    create_table "institutions", id: :serial do |t|
      t.string "name", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "slug", null: false
      t.boolean "show_on_list", default: false
      t.datetime "deleted_at", precision: nil
      t.integer "code_region"
      t.boolean "display_logo", default: false
      t.text "siren"
      t.index ["code_region"], name: "index_institutions_on_code_region"
      t.index ["deleted_at"], name: "index_institutions_on_deleted_at"
      t.index ["name"], name: "index_institutions_on_name", unique: true
      t.index ["slug"], name: "index_institutions_on_slug", unique: true
      t.index ["updated_at"], name: "index_institutions_on_updated_at"
    end
    create_table "institutions_subjects", id: :serial do |t|
      t.string "description"
      t.bigint "institution_id"
      t.bigint "subject_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.boolean "optional", default: false
      t.index ["institution_id"], name: "index_institutions_subjects_on_institution_id"
      t.index ["subject_id", "institution_id", "description"], name: "unique_institution_subject_in_institution", unique: true
      t.index ["subject_id"], name: "index_institutions_subjects_on_subject_id"
      t.index ["updated_at"], name: "index_institutions_subjects_on_updated_at"
    end
    create_table "landing_joint_themes", id: :serial do |t|
      t.bigint "landing_id"
      t.bigint "landing_theme_id"
      t.integer "position"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["landing_id"], name: "index_landing_joint_themes_on_landing_id"
      t.index ["landing_theme_id"], name: "index_landing_joint_themes_on_landing_theme_id"
    end
    create_table "landing_subjects", id: :serial do |t|
      t.bigint "landing_theme_id", null: false
      t.bigint "subject_id", null: false
      t.string "title"
      t.string "slug"
      t.text "description"
      t.integer "position"
      t.string "meta_title"
      t.string "meta_description"
      t.string "form_title"
      t.text "form_description"
      t.text "description_explanation"
      t.boolean "requires_siret", default: false, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.boolean "display_region_logo", default: false
      t.datetime "archived_at", precision: nil
      t.index ["archived_at"], name: "index_landing_subjects_on_archived_at"
      t.index ["landing_theme_id"], name: "index_landing_subjects_on_landing_theme_id"
      t.index ["slug"], name: "index_landing_subjects_on_slug", unique: true
      t.index ["subject_id"], name: "index_landing_subjects_on_subject_id"
    end
    create_table "landing_subjects_logos", id: :serial do |t|
      t.bigint "logo_id"
      t.bigint "landing_subject_id"
      t.index ["landing_subject_id"], name: "index_landing_subjects_logos_on_landing_subject_id"
      t.index ["logo_id"], name: "index_landing_subjects_logos_on_logo_id"
    end
    create_table "landing_themes", id: :serial do |t|
      t.string "title"
      t.string "page_title"
      t.string "slug"
      t.text "description"
      t.string "meta_title"
      t.string "meta_description"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.datetime "archived_at", precision: nil
      t.index ["archived_at"], name: "index_landing_themes_on_archived_at"
      t.index ["slug"], name: "index_landing_themes_on_slug", unique: true
    end
    create_table "landings", id: :serial do |t|
      t.string "slug", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.text "home_description", default: ""
      t.bigint "institution_id"
      t.string "meta_title"
      t.string "meta_description"
      t.string "title"
      t.string "custom_css"
      t.string "partner_url"
      t.boolean "emphasis", default: false
      t.string "main_logo"
      t.integer "layout", default: 1
      t.boolean "iframe", default: false
      t.integer "iframe_category", default: 1
      t.boolean "display_pde_partnership_mention", default: false
      t.datetime "archived_at", precision: nil
      t.index ["archived_at"], name: "index_landings_on_archived_at"
      t.index ["institution_id"], name: "index_landings_on_institution_id"
      t.index ["slug"], name: "index_landings_on_slug", unique: true
    end
    create_table "logos", id: :serial do |t|
      t.string "filename"
      t.string "name"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "institution_id"
      t.index ["institution_id"], name: "index_logos_on_institution_id"
    end
    create_table "match_filters", id: :serial do |t|
      t.string "accepted_naf_codes", array: true
      t.integer "effectif_min"
      t.integer "effectif_max"
      t.integer "min_years_of_existence"
      t.bigint "subject_id"
      t.bigint "antenne_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "max_years_of_existence"
      t.string "accepted_legal_forms", array: true
      t.index ["antenne_id"], name: "index_match_filters_on_antenne_id"
      t.index ["subject_id"], name: "index_match_filters_on_subject_id"
    end
    create_table "matches", id: :serial do |t|
      t.bigint "need_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.datetime "taken_care_of_at", precision: nil
      t.datetime "closed_at", precision: nil
      t.bigint "expert_id"
      t.bigint "subject_id", null: false
      t.enum "status", default: "quo", null: false, enum_type: "match_status"
      t.datetime "archived_at", precision: nil
      t.index ["expert_id", "need_id"], name: "index_matches_on_expert_id_and_need_id", unique: true, where: "(expert_id <> NULL::bigint)"
      t.index ["expert_id"], name: "index_matches_on_expert_id"
      t.index ["need_id"], name: "index_matches_on_need_id"
      t.index ["status"], name: "index_matches_on_status"
      t.index ["subject_id"], name: "index_matches_on_subject_id"
    end
    create_table "needs", id: :serial do |t|
      t.bigint "diagnosis_id", null: false
      t.bigint "subject_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.text "content"
      t.integer "matches_count"
      t.datetime "archived_at", precision: nil
      t.boolean "satisfaction_email_sent", default: false, null: false
      t.enum "status", default: "diagnosis_not_complete", null: false, enum_type: "need_status"
      t.boolean "abandoned_email_sent", default: false
      t.index ["archived_at"], name: "index_needs_on_archived_at"
      t.index ["diagnosis_id"], name: "index_needs_on_diagnosis_id"
      t.index ["status"], name: "index_needs_on_status"
      t.index ["subject_id", "diagnosis_id"], name: "index_needs_on_subject_id_and_diagnosis_id", unique: true
      t.index ["subject_id"], name: "index_needs_on_subject_id"
    end
    create_table "quarterly_reports" do |t|
      t.date "start_date"
      t.date "end_date"
      t.bigint "antenne_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.enum "category", enum_type: "quarterly_reports_categories"
      t.index ["antenne_id"], name: "index_quarterly_reports_on_antenne_id"
      t.index ["category"], name: "index_quarterly_reports_on_category"
    end
    create_table "reminders_actions", id: :serial do |t|
      t.bigint "need_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "category", null: false
      t.index ["need_id", "category"], name: "index_reminders_actions_on_need_id_and_category", unique: true
      t.index ["need_id"], name: "index_reminders_actions_on_need_id"
    end
    create_table "searches", id: :serial do |t|
      t.string "query", null: false
      t.bigint "user_id", null: false
      t.string "label"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["query"], name: "index_searches_on_query"
      t.index ["user_id"], name: "index_searches_on_user_id"
    end
    create_table "solicitations", id: :serial do |t|
      t.string "description"
      t.string "email"
      t.string "phone_number"
      t.jsonb "form_info", default: {}
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "siret"
      t.string "full_name"
      t.string "landing_slug"
      t.jsonb "prepare_diagnosis_errors_details", default: {}
      t.string "requested_help_amount"
      t.string "location"
      t.bigint "institution_id"
      t.integer "code_region"
      t.boolean "created_in_deployed_region", default: false
      t.bigint "landing_id"
      t.bigint "landing_subject_id"
      t.boolean "banned", default: false
      t.integer "status", default: 0
      t.uuid "uuid"
      t.index ["code_region"], name: "index_solicitations_on_code_region"
      t.index ["email"], name: "index_solicitations_on_email"
      t.index ["institution_id"], name: "index_solicitations_on_institution_id"
      t.index ["landing_id"], name: "index_solicitations_on_landing_id"
      t.index ["landing_slug"], name: "index_solicitations_on_landing_slug"
      t.index ["landing_subject_id"], name: "index_solicitations_on_landing_subject_id"
      t.index ["status"], name: "index_solicitations_on_status"
      t.index ["uuid"], name: "index_solicitations_on_uuid"
    end
    create_table "subjects", id: :serial do |t|
      t.string "label", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "theme_id", null: false
      t.integer "interview_sort_order"
      t.datetime "archived_at", precision: nil
      t.boolean "is_support", default: false
      t.string "slug", null: false
      t.index ["archived_at"], name: "index_subjects_on_archived_at"
      t.index ["interview_sort_order"], name: "index_subjects_on_interview_sort_order"
      t.index ["label"], name: "index_subjects_on_label", unique: true
      t.index ["slug"], name: "index_subjects_on_slug", unique: true
      t.index ["theme_id"], name: "index_subjects_on_theme_id"
    end
    create_table "territories", id: :serial do |t|
      t.string "name"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.boolean "bassin_emploi", default: false, null: false
      t.bigint "support_contact_id"
      t.integer "code_region"
      t.datetime "deployed_at", precision: nil
      t.index ["code_region"], name: "index_territories_on_code_region"
      t.index ["support_contact_id"], name: "index_territories_on_support_contact_id"
    end
    create_table "themes", id: :serial do |t|
      t.string "label", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "interview_sort_order"
      t.index ["interview_sort_order"], name: "index_themes_on_interview_sort_order"
      t.index ["label"], name: "index_themes_on_label", unique: true
      t.index ["updated_at"], name: "index_themes_on_updated_at"
    end
    create_table "user_rights" do |t|
      t.bigint "antenne_id"
      t.bigint "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "category", null: false
      t.index ["antenne_id"], name: "index_user_rights_on_antenne_id"
      t.index ["user_id", "antenne_id", "category"], name: "index_user_rights_on_user_id_and_antenne_id_and_category", unique: true
      t.index ["user_id"], name: "index_user_rights_on_user_id"
    end
    create_table "users", id: :serial do |t|
      t.string "email", default: ""
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at", precision: nil
      t.datetime "remember_created_at", precision: nil
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at", precision: nil
      t.datetime "last_sign_in_at", precision: nil
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "phone_number"
      t.string "job"
      t.string "full_name"
      t.bigint "antenne_id", null: false
      t.string "invitation_token"
      t.datetime "invitation_created_at", precision: nil
      t.datetime "invitation_sent_at", precision: nil
      t.datetime "invitation_accepted_at", precision: nil
      t.integer "invitation_limit"
      t.bigint "inviter_id"
      t.integer "invitations_count", default: 0
      t.datetime "deleted_at", precision: nil
      t.datetime "cgu_accepted_at", precision: nil
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
    add_foreign_key "facilities", "institutions", column: "opco_id"
    add_foreign_key "feedbacks", "users"
    add_foreign_key "institutions_subjects", "institutions"
    add_foreign_key "institutions_subjects", "subjects"
    add_foreign_key "landing_subjects", "landing_themes"
    add_foreign_key "landing_subjects", "subjects"
    add_foreign_key "landings", "institutions"
    add_foreign_key "logos", "institutions"
    add_foreign_key "match_filters", "antennes"
    add_foreign_key "match_filters", "subjects"
    add_foreign_key "matches", "experts"
    add_foreign_key "matches", "needs"
    add_foreign_key "matches", "subjects"
    add_foreign_key "needs", "diagnoses"
    add_foreign_key "needs", "subjects"
    add_foreign_key "quarterly_reports", "antennes"
    add_foreign_key "reminders_actions", "needs"
    add_foreign_key "searches", "users"
    add_foreign_key "solicitations", "institutions"
    add_foreign_key "solicitations", "landing_subjects"
    add_foreign_key "solicitations", "landings"
    add_foreign_key "subjects", "themes"
    add_foreign_key "user_rights", "antennes"
    add_foreign_key "user_rights", "users"
    add_foreign_key "users", "antennes"
    add_foreign_key "users", "users", column: "inviter_id"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
