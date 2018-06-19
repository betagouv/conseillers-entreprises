class RenameSelectedAssistanceExpertToMatch < ActiveRecord::Migration[5.1]
  def up
    rename_table :selected_assistances_experts, :matches
    Audited.audit_class.where(auditable_type: 'SelectedAssistanceExpert').find_each do |a|
      a.auditable_type = 'Match'
      a.save!
    end
  end

  def down
    rename_table :matches, :selected_assistances_experts
    Audited.audit_class.where(auditable_type: 'Match').find_each do |a|
      a.auditable_type = 'SelectedAssistanceExpert'
      a.save!
    end
  end
end
