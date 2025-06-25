module CsvExport
  class AntenneExporter < BaseExporter
    def fields
      {
        institution: -> { institution.name },
        name: :name,
        communes_codes: -> { territorial_zones.with_communes.map(&:code).join(' ') if territorial_zones.with_communes.any? },
        epcis_codes: -> { territorial_zones.with_epcis.map(&:code).join(' ') if territorial_zones.with_epcis.any? },
        departements_codes: -> { territorial_zones.with_departements.map(&:code).join(' ') if territorial_zones.with_departements.any? },
        region_codes: -> { territorial_zones.with_regions.map(&:code).join(' ') if territorial_zones.with_regions.any? },
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
