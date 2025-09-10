class MigrateTerritoriesForThemes < ActiveRecord::Migration[7.2]
  def up
    Theme.find_each do |theme|
      next if theme.territories.blank?
      code = if theme.territories.first.code_region.to_s.length == 1
        "0#{theme.territories.first.code_region}"
      else
        theme.territories.first.code_region
      end

      theme.territorial_zones.create!(zoneable: theme, zone_type: :region, code: code)
    end
  end
end
