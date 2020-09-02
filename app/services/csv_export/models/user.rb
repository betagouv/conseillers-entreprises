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

        def csv_fields_for_relevant_expert_team
          {
            team_full_name: -> { relevant_expert.full_name if relevant_expert.team? },
            team_email: -> { relevant_expert.email if relevant_expert.team? },
            team_phone_number: -> { relevant_expert.phone_number if relevant_expert.team? },
            team_role: -> { relevant_expert.role if relevant_expert.team? },
          }
        end

        def csv_fields_for_relevant_expert_subjects(subjects)
          subjects.map do |institution_subject|
            # We’re doing CSV-in-CSV in here:
            # * `csv_identifier` concatenates the theme, subject and description of the institution_subject
            # * `csv_description` concatenates the role and description of the expert_subject, and if there are several, concatenates them.
            title = institution_subject.csv_identifier
            lambda = -> {
              # This block is executed in the context of a User (`self` is a User);
              # See `object.instance_exec(&lambda)` in CsvExportService.
              # We’re using `&` instead of .merge to use the preloaded relations instead of doing a new DB query.
              experts_subjects = relevant_expert.experts_subjects & institution_subject.experts_subjects
              experts_subjects.map(&:csv_description).to_csv.strip
            }
            [title, lambda]
          end.to_h
        end
      end
    end
  end
end
