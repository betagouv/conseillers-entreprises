class AddSatisfactionThirdQuestion < ActiveRecord::Migration[8.1]
  def change
    add_column :company_satisfactions, :outcome_discover_support, :boolean
    add_column :company_satisfactions, :outcome_start_action, :boolean
    add_column :company_satisfactions, :outcome_help_choice, :boolean
    add_column :company_satisfactions, :outcome_other, :boolean
  end
end
