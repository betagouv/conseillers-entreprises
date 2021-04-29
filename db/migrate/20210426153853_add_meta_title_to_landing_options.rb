class AddMetaTitleToLandingOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :landing_options, :meta_title, :string
  end
end
