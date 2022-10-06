class ChangeDefaultSiretToLandingSubjects < ActiveRecord::Migration[7.0]
  def change
    change_column_default :landing_subjects, :requires_siret, from: false, to: true
  end
end
