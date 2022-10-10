class ChangeRequireSiretForLandingSubjects < ActiveRecord::Migration[7.0]
  def change
    change_column :landing_subjects, :requires_siret, :boolean, default: true
  end
end
