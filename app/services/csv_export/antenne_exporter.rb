module CsvExport
  class AntenneExporter < BaseExporter
    def fields
      {
        institution: -> { institution.name },
        name: :name,
        communes_codes: -> { territorial_zones.zone_type_commune.map(&:code).join(' ') if territorial_zones.zone_type_commune.any? },
        epcis_codes: -> { territorial_zones.zone_type_epci.map(&:code).join(' ') if territorial_zones.zone_type_epci.any? },
        departements_codes: -> { territorial_zones.zone_type_departement.map(&:code).join(' ') if territorial_zones.zone_type_departement.any? },
        region_codes: -> { territorial_zones.zone_type_region.map(&:code).join(' ') if territorial_zones.zone_type_region.any? },
        manager_full_name: -> { managers.pluck(:full_name).join(', ') if managers.any? },
        manager_email:  -> { managers.pluck(:email).join(', ') if managers.any? },
        manager_phone:  -> { managers.pluck(:phone_number).join(', ') if managers.any? },
      }
    end

    def preloaded_associations
      [
        :institution,
        :territorial_zones,
        :managers
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by(&:name)
    end
  end
end
