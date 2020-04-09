class AddContentToLandingOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :landing_options, :content, :jsonb, default: {}
  end
end
