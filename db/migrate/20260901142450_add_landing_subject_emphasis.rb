class AddLandingSubjectEmphasis < ActiveRecord::Migration[8.1]
  def change
    add_column :landing_subjects, :emphasis, :boolean, default: false, null: false
    add_column :landing_subjects, :home_description, :text, default: ""
  end
end
