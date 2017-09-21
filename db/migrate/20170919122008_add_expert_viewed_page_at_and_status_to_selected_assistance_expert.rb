# frozen_string_literal: true

class AddExpertViewedPageAtAndStatusToSelectedAssistanceExpert < ActiveRecord::Migration[5.1]
  def change
    add_column :selected_assistances_experts, :expert_viewed_page_at, :datetime
    add_column :selected_assistances_experts, :status, :integer
  end
end
