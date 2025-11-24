class FixSchema < ActiveRecord::Migration[7.2]
  def change
    add_index :reminders_actions, %w[category need_id], name: :index_reminders_actions_category_need_id, unique: true
    # add_index :diagnoses, :solicitation_id, name: :index_diagnoses_solicitation_id, unique: true
    add_index :badge_badgeables, %w[badgeable_id badgeable_type], name: :index_badge_badgeables_badgeable_id_badgeable_type
    # add_index :company_satisfactions, :need_id, name: :index_company_satisfactions_need_id, unique: true
    add_index :api_keys, :institution_id, name: :index_api_keys_institution_id, unique: true
    add_index :activity_reports, :reportable_id, name: :index_activity_reports_reportable_id

    remove_index 'user_rights', name: 'index_user_rights_on_user_id'
    remove_index 'subject_questions', name: 'index_subject_questions_on_subject_id'
    remove_index 'shared_satisfactions', name: 'index_shared_satisfactions_on_user_id'
    remove_index 'reminders_actions', name: 'index_reminders_actions_on_need_id'
    remove_index 'institutions_subjects', name: 'index_institutions_subjects_on_subject_id'
    remove_index 'experts_subjects', name: 'index_experts_subjects_on_expert_id'
    remove_index 'needs', name: 'index_needs_on_subject_id'

    change_column_null :subject_questions, :key, false
    change_column_null :match_filters, :filtrable_element_type, false
    change_column_null :landing_joint_themes, :landing_theme_id, false
    change_column_null :landing_joint_themes, :landing_id, false
    change_column_null :institutions_subjects, :institution_id, false
    change_column_null :institutions_subjects, :subject_id, false
    change_column_null :experts_subjects, :expert_id, false
    change_column_null :experts_subjects, :institution_subject_id, false
    change_column_null :communes, :insee_code, false
    change_column_null :badge_badgeables, :badge_id, false
    change_column_null :activity_reports, :reportable_id, false
    change_column_null :activity_reports, :reportable_type, false
    change_column_null :landing_themes, :slug, false
    change_column_null :feedbacks, :feedbackable_id, false
    change_column_null :feedbacks, :feedbackable_type, false
    change_column_null :feedbacks, :user_id, false
    change_column_null :feedbacks, :description, false
    change_column_null :experts, :full_name, false
    # change_column_null :users, :full_name, false
    change_column_null :users, :job, false
    change_column_null :contacts, :full_name, false
    change_column_null :companies, :name, false
    change_column_null :antennes, :name, false
    change_column_null :subjects, :is_support, false
    change_column_null :needs, :abandoned_email_sent, false
    change_column_null :landings, :emphasis, false
    change_column_null :institutions, :show_on_list, false
    change_column_null :institutions, :display_logo_on_home_page, false
    change_column_null :institutions, :display_logo_in_partner_list, false
    change_column_null :experts, :is_global_zone, false
    change_column_null :diagnoses, :retention_email_sent, false
    change_column_null :cooperations, :display_url, false
    change_column_null :cooperations, :display_pde_partnership_mention, false
    change_column_null :cooperations, :display_matches_stats, false
    change_column_null :cooperations, :external, false
    change_column_null :company_satisfactions, :contacted_by_expert, false
    change_column_null :company_satisfactions, :useful_exchange, false

    change_column :subjects, :id, :bigint
    change_column :users, :id, :bigint
    change_column :companies, :id, :bigint

    # add_foreign_key :user_rights, :antennes, column: :rightable_element_id, primary_key: :id
    # add_foreign_key :user_rights, :cooperations, column: :rightable_element_id, primary_key: :id
    # add_foreign_key :user_rights, :territorial_zones, column: :rightable_element_id, primary_key: :id
    add_foreign_key :territories, :users, column: :support_contact_id, primary_key: :id
    add_foreign_key :subject_questions, :subjects, column: :subject_id, primary_key: :id
    add_foreign_key :subject_answers, :subject_questions, column: :subject_question_id, primary_key: :id
    add_foreign_key :landing_joint_themes, :landing_themes, column: :landing_theme_id, primary_key: :id
    add_foreign_key :landing_joint_themes, :landings, column: :landing_id, primary_key: :id
    # add_foreign_key :feedbacks, :needs, column: :feedbackable_id, primary_key: :id
    # add_foreign_key :feedbacks, :solicitations, column: :feedbackable_id, primary_key: :id
    # add_foreign_key :feedbacks, :experts, column: :feedbackable_id, primary_key: :id
    add_foreign_key :antennes, :antennes, column: :parent_antenne_id, primary_key: :id
    # add_foreign_key :subject_answers, :subject_answer_groupings, column: :subject_answer_grouping_id, primary_key: :id
  end
end
