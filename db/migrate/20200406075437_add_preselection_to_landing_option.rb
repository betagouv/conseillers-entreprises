class AddPreselectionToLandingOption < ActiveRecord::Migration[6.0]
  def change
    add_index :landing_options, :slug, unique: true

    add_column :landing_options, :preselected_subject_slug, :string
    add_column :landing_options, :preselected_institution_slug, :string
  end
end
