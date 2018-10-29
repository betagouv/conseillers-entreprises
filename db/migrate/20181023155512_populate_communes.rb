class PopulateCommunes < ActiveRecord::Migration[5.2]
  def up
    Facility.find_each { |facility| facility.update(commune: Commune.find_or_create_by(insee_code: facility.city_code)) }
    change_column_null :facilities, :commune_id, false

    TerritoryCity.find_each { |tc| tc.update(commune: Commune.find_or_create_by(insee_code: tc.city_code)) }
    change_column_null :territory_cities, :commune_id, false

    change_column_null :territory_cities, :territory_id, false
  end

  def down
    change_column_null :territory_cities, :territory_id, true

    change_column_null :territory_cities, :commune_id, true
    TerritoryCity.find_each { |tc| tc.update(commune: nil) }

    change_column_null :facilities, :commune_id, true
    Facility.find_each { |facility| facility.update(commune: nil) }

    Commune.destroy_all
  end
end
