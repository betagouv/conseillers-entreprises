module CsvImport
  ## UserImporter needs an :institution to be passed in the options
  class UserImporter < BaseImporter
    def mapping
      @mapping ||=
        %i[institution antenne full_name email phone_number role]
          .index_by{ |k| User.human_attribute_name(k) }
    end

    def check_headers(headers)
      static_headers = mapping.keys + team_mapping.keys + one_subject_mapping.keys
      build_several_subjects_mapping(headers, static_headers)
      known_headers = static_headers + several_subjects_mapping.keys
      headers.filter_map do |header|
        UnknownHeaderError.new(header) unless known_headers.include? header.squish
      end
    end

    def preprocess(attributes)
      attributes = sanitize_inputs(attributes)
      institution = Institution.find_by(name: attributes[:institution]) || @options[:institution]
      antenne = Antenne.flexible_find_or_initialize institution, attributes[:antenne]
      attributes.delete(:institution)
      attributes[:antenne] = antenne
    end

    def sanitize_inputs(attributes)
      attributes[:institution] = attributes[:institution].strip if attributes[:institution].present?
      attributes[:antenne] = attributes[:antenne].strip if attributes[:antenne].present?
      attributes[:email] = attributes[:email].strip.downcase if attributes[:email].present?
      attributes
    end

    def find_instance(attributes)
      return User.find_or_initialize_by(email: attributes[:email]), attributes # Handle casing, see #1408
    end

    def postprocess(user, attributes)
      team = import_team(user, attributes)
      expert = team || user.personal_skillsets.first
      if expert.present?
        import_several_subjects(expert, attributes)
        import_one_subject(expert, attributes)

        # Force-trigger validations in User: expert can be already in the user experts, not in the experts but saved, or not saved at all.
        # Setting .experts = to a failing object raises an error, and we don‘t want that
        if expert.persisted?
          other_experts = user.experts - [expert]
          user.experts = other_experts + [expert]
        else
          user.experts.build(expert.attributes)
        end
      end
    end

    def team_mapping
      @team_mapping ||=
        %i[team_email team_full_name team_phone_number]
          .index_by{ |k| User.human_attribute_name(k) }
    end

    def import_team(user, all_attributes)
      attributes = all_attributes.slice(*team_mapping.keys)
        .transform_keys{ |k| team_mapping[k] }
        .transform_keys{ |k| k.to_s.delete_prefix('team_').to_sym }
        .select { |_, v| v.present? }
      attributes = sanitize_inputs(attributes)

      if attributes[:email].present?
        attributes[:antenne] = user.antenne
        team = @options[:institution].experts.find_or_initialize_by(email: attributes[:email])
        team.update(attributes)

        team
      end
    end

    def build_several_subjects_mapping(headers, other_known_headers)
      @several_subjects_mapping =
        headers
          .without(other_known_headers)
          .index_with { |header| InstitutionSubject.find_with_name(@options[:institution], header) }
          .compact
    end

    def several_subjects_mapping
      @several_subjects_mapping
    end

    def import_several_subjects(expert, all_attributes)
      experts_subjects_attributes = all_attributes.slice(*several_subjects_mapping.keys)
        .transform_keys{ |k| several_subjects_mapping[k] }.filter_map do |institution_subject, serialized_description|
        {
          institution_subject: institution_subject,
          csv_description: serialized_description
        }
      end

      experts_subjects_attributes.each do |attributes|
        experts_subject = expert.experts_subjects.find_by(institution_subject_id: attributes[:institution_subject].id)
        # `serialized_description = nil` => l'expert avait le sujet mais ne l'a plus, donc à supprimer
        if experts_subject.present? && attributes[:csv_description].nil?
          experts_subject.destroy
        elsif experts_subject.nil? && attributes[:csv_description].present? # sujet à rajouter si l'expert ne l'avait pas déjà
          # On teste la validite pour éviter " You cannot call create unless the parent is saved"
          expert.experts_subjects.create(attributes) if expert.valid?
        end
      end
    end

    def one_subject_mapping
      { Expert.human_attribute_name(:subject) => :subject }
    end

    def import_one_subject(expert, all_attributes)
      name = all_attributes[Expert.human_attribute_name('subject')]
      return if name.blank?

      institution_subject = InstitutionSubject.find_with_name(expert.institution, name)

      # Avoid duplicate ExpertsSubjects
      return if expert.institutions_subjects.include? institution_subject

      expert.experts_subjects.new(institution_subject: institution_subject)
      expert.save
    end
  end
end
