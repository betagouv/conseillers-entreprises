class RemoveSlugUniquenessOnLandingSubjects < ActiveRecord::Migration[7.0]
  def change
    remove_index :landing_subjects, :slug, unique: true
    add_index :landing_subjects, [:slug, :landing_theme_id], unique: true
  end
end
