module CsvExport
  module Models
    module Antenne
      extend ActiveSupport::Concern
      class_methods do
        def csv_fields
          {
            institution: -> { institution.name },
            name: :name,
            insee_codes: :insee_codes
          }
        end

        def csv_preloaded_associations
          [
            :institution,
            :communes,
          ]
        end
      end
    end
  end
end
