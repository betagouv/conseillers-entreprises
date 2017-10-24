# frozen_string_literal: true

class AddTerritoryUserToSelectedAssistanceExpert < ActiveRecord::Migration[5.1]
  def change
    add_reference :selected_assistances_experts, :territory_user, foreign_key: true
  end
end
