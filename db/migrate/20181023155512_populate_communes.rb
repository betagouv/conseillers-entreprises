class PopulateCommunes < ActiveRecord::Migration[5.2]
  def up
    Facility.find_each { |facility| facility.update(commune: Commune.find_or_create_by(insee_code: facility.city_code)) }
    TerritoryCity.find_each { |tc| tc.update(commune: Commune.find_or_create_by(insee_code: tc.city_code)) }
  end

  def down
    TerritoryCity.find_each { |tc| tc.update(commune: nil) }
    Facility.find_each { |facility| facility.update(commune: nil) }

    Commune.destroy_all
  end
end
