module CsvExport
  # UserExporter supports two options.
  # Both require the relation to be fetched using User.relevant_for_skills.
  # include_expert
  # institutions_subjects: the institutions_subjects to add as csv columns for the relevant expert.
  class UserExporter < BaseExporter
    def fields
      fields = base_fields
      fields.merge!(fields_for_team) if @options[:include_expert]
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
        job: :job,
      }
    end

    def preloaded_associations
      [
        :institution, :antenne
      ]
    end

    def fields_for_team
      {
        team_id: -> { first_expert_with_subject&.id },
        team_full_name: -> { first_expert_with_subject&.full_name },
        team_email: -> { first_expert_with_subject&.email },
        team_phone_number: -> { first_expert_with_subject&.phone_number },
        team_custom_territories: -> { first_expert_with_subject&.territorial_zones.pluck(:code).join(', ') if first_expert_with_subject&.custom_territories? }
      }
    end

    def fields_for_subjects
      @options[:institutions_subjects].to_h do |institution_subject|
        # We build a hash of <institution subject>: <expert subject>
        # * There can be only one expert_subject for an (expert, institution_subject) pair.
        title = institution_subject.unique_name
        lambda = -> {
          # This block is executed in the context of a User
          # (`self` is a User; See `object.instance_exec(&lambda)` in CsvExport::Base.)

          # We’re using `&` instead of .merge to use the preloaded relations instead of doing a new DB query.
          return if first_expert_with_subject.blank?
          experts_subjects = first_expert_with_subject&.experts_subjects & institution_subject.experts_subjects
          raise 'There should only be one ExpertSubject' if experts_subjects.present? && experts_subjects.size > 1
          expert_subject = experts_subjects.first
          expert_subject&.csv_description
        }
        [title, lambda]
      end
    end

    def sort_relation(relation)
      relation.preload(*preloaded_associations).sort_by{ |u| [u.antenne.name, u.experts.first&.full_name.to_s] }
    end
  end
end
