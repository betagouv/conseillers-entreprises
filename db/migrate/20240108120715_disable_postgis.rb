class DisablePostgis < ActiveRecord::Migration[7.0]
  def change
    if Rails.env.production?
      disable_extension "postgis"
    end
  end
end
