module CsvImport
  class UserImporter < BaseImporter
    def initialize(file, institution)
      @institution = institution
      super(file)
    end

    def mapping
      @mapping ||=
        %i[institution antenne full_name email phone_number role]
          .index_by{ |k| User.human_attribute_name(k) }
    end

    def check_headers(headers)
      static_headers = mapping.keys + team_mapping.keys + one_subject_mapping.keys
      build_several_subjects_mapping(headers, static_headers)
      known_headers = static_headers + several_subjects_mapping.keys
      headers.map do |header|
        UnknownHeaderError.new(header) unless known_headers.include? header
      end.compact
    end

    def preprocess(attributes)
      institution = Institution.find_by(name: attributes[:institution])
      antenne = Antenne.find_by(institution: institution, name: attributes[:antenne])
      attributes.delete(:institution)
      attributes[:antenne] = antenne
    end

    def find_instance(attributes)
      User.find_or_initialize_by(email: attributes[:email])
    end

    def postprocess(user, attributes)
      team = import_team(user, attributes)
      expert = team || user.personal_skillsets.first
      if expert.present?
        import_several_subjects(expert, attributes)
        import_one_subject(expert, attributes)
        # Force-trigger validations in User
        # Removing and Adding the same object to the relation _works_: ActiveRecords remove the object of the same id,
        # then add the new in-memory object.
        other_experts = user.experts - [expert]
        user.experts = other_experts + [expert]
      end
    end

    def team_mapping
      @team_mapping ||=
        %i[team_email team_full_name team_phone_number team_role]
          .index_by{ |k| User.human_attribute_name(k) }
    end

    def import_team(user, all_attributes)
      attributes = all_attributes.slice(*team_mapping.keys)
        .transform_keys{ |k| team_mapping[k] }
        .transform_keys{ |k| k.to_s.delete_prefix('team_').to_sym }
        .select { |_, v| v.present? }

      if attributes[:email].present?
        attributes[:antenne] = user.antenne
        team = Expert.find_or_initialize_by(email: attributes[:email])
        team.update(attributes)

        unless user.experts.include? team
          user.experts << team
        end

        team
      end
    end

    def build_several_subjects_mapping(headers, other_known_headers)
      @several_subjects_mapping =
        headers
          .without(other_known_headers)
          .index_with { |header| @institution.find_institution_subject(header) }
          .compact
    end

    def several_subjects_mapping
      @several_subjects_mapping
    end

    def import_several_subjects(expert, all_attributes)
      attributes = all_attributes.slice(*several_subjects_mapping.keys)
        .transform_keys{ |k| several_subjects_mapping[k] }

      experts_subjects = attributes.map do |institution_subject, serialized_description|
        # TODO: serialized_description may be an array of hashes
        if serialized_description.present?
          expert_subject_attributes = {
            institution_subject: institution_subject,
            csv_description: serialized_description
          }

          ExpertSubject.new(expert_subject_attributes)
        end
      end

      expert.experts_subjects = experts_subjects.compact
    end

    def one_subject_mapping
      { Expert.human_attribute_name(:subject) => :subject }
    end

    def import_one_subject(expert, all_attributes)
      identifier = all_attributes[Expert.human_attribute_name('subject')]
      return if identifier.blank?

      institution_subject = expert.institution.institutions_subjects.find{ |is| is.csv_identifier == identifier }

      expert_subject_attributes = {
        institution_subject: institution_subject,
        role: :specialist
      }
      expert.experts_subjects.clear
      expert.experts_subjects.create(expert_subject_attributes)
      expert.save
    end
  end
end
