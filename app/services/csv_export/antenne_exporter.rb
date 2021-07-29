module CsvExport
  class AntenneExporter < BaseExporter
    def fields
      {
        institution: -> { institution.name },
        name: :name,
        insee_codes: :insee_codes
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
