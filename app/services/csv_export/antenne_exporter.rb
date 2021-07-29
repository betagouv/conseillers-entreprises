module CsvExport
  class AntenneExporter < BaseExporter
    def fields
      {
        institution: -> { institution.name },
        name: :name,
        insee_codes: :insee_codes,
        manager_full_name: :manager_full_name,
        manager_email: :manager_email,
        manager_phone: :manager_phone
      }
    end

    def preloaded_associations
      [
        :institution,
        :communes,
      ]
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by(&:name)
    end
  end
end
