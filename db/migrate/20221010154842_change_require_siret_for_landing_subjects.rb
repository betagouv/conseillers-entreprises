class ChangeRequireSiretForLandingSubjects < ActiveRecord::Migration[7.0]
  def up
    change_column :landing_subjects, :requires_siret, :boolean, default: true
  end

  def down
    change_column :landing_subjects, :requires_siret, :boolean, default: false
  end
end
