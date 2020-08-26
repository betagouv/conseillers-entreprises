module CsvExport
  module Models
    module User
      extend ActiveSupport::Concern
      class_methods do
        def csv_fields
          {
            institution: -> { institution.name },
            antenne: -> { antenne.name },
            full_name: :full_name,
            email: :email,
            phone_number: :phone_number,
            role: :role,
          }
        end

        def csv_preloaded_associations
          [
            :institution, :antenne
          ]
        end
      end
    end
  end
end
