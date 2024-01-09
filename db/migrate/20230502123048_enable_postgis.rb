class EnablePostgis < ActiveRecord::Migration[7.0]
  def change
    if Rails.env.production?
      enable_extension "postgis"
    end
  end
end
