class AddTakenCareOfAtAndClosedAtToSelectedAssistanceExpert < ActiveRecord::Migration[5.1]
  def change
    add_column :selected_assistances_experts, :taken_care_of_at, :datetime
    add_column :selected_assistances_experts, :closed_at, :datetime
  end
end
