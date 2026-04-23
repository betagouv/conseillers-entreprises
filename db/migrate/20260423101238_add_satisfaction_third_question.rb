class AddSatisfactionThirdQuestion < ActiveRecord::Migration[8.1]
  def change
    create_enum :company_satisfaction_outcome, %i[find_institution find_measure start_action help_choice other]
    add_column :company_satisfactions, :outcome, :company_satisfaction_outcome
  end
end
