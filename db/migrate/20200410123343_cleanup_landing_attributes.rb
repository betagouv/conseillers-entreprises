class CleanupLandingAttributes < ActiveRecord::Migration[6.0]
  def change
    remove_column :landing_options, :description, :text

    change_column_default :landings, :home_title, ''
    change_column_default :landings, :home_description, ''
  end
end
