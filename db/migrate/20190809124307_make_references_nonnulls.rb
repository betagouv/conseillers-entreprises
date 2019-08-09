class MakeReferencesNonnulls < ActiveRecord::Migration[5.2]
  def change
    change_column_null :contacts, :company_id, false
    change_column_null :diagnoses, :advisor_id, false
    change_column_null :experts_skills, :skill_id, false
    change_column_null :experts_skills, :expert_id, false
    change_column_null :experts_users, :expert_id, false
    change_column_null :experts_users, :user_id, false
    change_column_null :facilities, :company_id, false
    change_column_null :feedbacks, :match_id, false
    change_column_null :landing_topics, :landing_id, false
    change_column_null :matches, :need_id, false
    change_column_null :needs, :diagnosis_id, false
    change_column_null :searches, :user_id, false
  end
end
