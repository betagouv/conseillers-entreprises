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
        team_id: -> { expert_team_for_export&.id },
        team_full_name: -> { expert_team_for_export&.full_name },
        team_email: -> { expert_team_for_export&.email },
        team_phone_number: -> { expert_team_for_export&.phone_number },
        team_custom_communes: -> { expert_team_for_export&.territorial_zones.zone_type_commune.pluck(:code).join(', ') if expert_team_for_export&.territorial_zones&.zone_type_commune&.any? },
        team_custom_epcis: -> { expert_team_for_export&.territorial_zones.zone_type_epci.pluck(:code).join(', ') if expert_team_for_export&.territorial_zones&.zone_type_epci&.any? },
        team_custom_departements: -> { expert_team_for_export&.territorial_zones.zone_type_departement.pluck(:code).join(', ') if expert_team_for_export&.territorial_zones&.zone_type_departement&.any? },
        team_custom_regions: -> { expert_team_for_export&.territorial_zones.zone_type_region.pluck(:code).join(', ') if expert_team_for_export&.territorial_zones&.zone_type_region&.any? },
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
          return if expert_team_for_export.blank?
          experts_subjects = expert_team_for_export&.experts_subjects & institution_subject.experts_subjects
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
