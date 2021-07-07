module CsvExport
  # UserExporter supports two options.
  # Both require the relation to be fetched using User.relevant_for_skills.
  # include_expert_team: include the “relevant_expert” team.
  # institutions_subjects: the institutions_subjects to add as csv columns for the relevant expert.
  class UserExporter < BaseExporter
    def fields
      fields = base_fields
      fields.merge!(fields_for_team) if @options[:include_expert_team]
      fields.merge!(fields_for_subjects) if @options[:institutions_subjects]

      fields
    end

    def base_fields
      {
        institution: -> { institution.name },
        antenne: -> { antenne.name },
        full_name: :full_name,
        email: :email,
        phone_number: :phone_number,
        role: :role,
      }
    end

    def preloaded_associations
      [
        :institution, :antenne
      ]
    end

    def fields_for_team
      {
        team_full_name: -> { relevant_expert.full_name if relevant_expert.team? },
        team_email: -> { relevant_expert.email if relevant_expert.team? },
        team_phone_number: -> { relevant_expert.phone_number if relevant_expert.team? }
      }
    end

    def fields_for_subjects
      @options[:institutions_subjects].map do |institution_subject|
        # We build a hash of <institution subject>: <expert subject>
        # * There can be only one expert_subject for an (expert, institution_subject) pair.
        title = institution_subject.unique_name
        lambda = -> {
          # This block is executed in the context of a User
          # (`self` is a User; See `object.instance_exec(&lambda)` in CsvExport::Base.)

          # We’re using `&` instead of .merge to use the preloaded relations instead of doing a new DB query.
          experts_subjects = relevant_expert.experts_subjects & institution_subject.experts_subjects
          raise 'There should only be one ExpertSubject' if experts_subjects.size > 1
          expert_subject = experts_subjects.first
          expert_subject&.csv_description
        }
        [title, lambda]
      end.to_h
    end
  end
end
