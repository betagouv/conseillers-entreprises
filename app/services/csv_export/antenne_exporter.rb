module CsvExport
  class AntenneExporter < BaseExporter
    def fields
      {
        institution: -> { institution.name },
        name: :name,
        insee_codes: :insee_codes,
        manager_full_name: -> { managers.pluck(:full_name).join(', ') },
        manager_email:  -> { managers.pluck(:email).join(', ') },
        manager_phone:  -> { managers.pluck(:phone_number).join(', ') },
      }
    end

    def preloaded_associations
      [
        :institution,
        :communes,
        :managers
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by(&:name)
    end
  end
end
