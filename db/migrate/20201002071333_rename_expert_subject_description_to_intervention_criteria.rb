class RenameExpertSubjectDescriptionToInterventionCriteria < ActiveRecord::Migration[6.0]
  def change
    rename_column :experts_subjects, :description, :intervention_criteria
  end
end
