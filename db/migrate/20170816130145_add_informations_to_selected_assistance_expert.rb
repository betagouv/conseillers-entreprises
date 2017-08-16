# frozen_string_literal: true

class AddInformationsToSelectedAssistanceExpert < ActiveRecord::Migration[5.1]
  def change
    add_column :selected_assistances_experts, :expert_full_name, :string
    add_column :selected_assistances_experts, :expert_institution_name, :string
    add_column :selected_assistances_experts, :assistance_title, :string
  end
end
