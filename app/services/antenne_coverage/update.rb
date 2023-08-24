module AntenneCoverage
  class Update
    attr_accessor :antenne

    def initialize(antenne)
      @antenne = antenne
    end

    def call
      antenne_insee_codes = @antenne.communes.pluck(:insee_code)
      institution_subjects = @antenne.institution.institutions_subjects

      institution_subjects.each do |institution_subject|
        subject_hash = antenne_insee_codes.index_with { [] }
        experts_without_specific_territories = get_experts_without_specific_territories(antenne_insee_codes, institution_subject)
        experts_with_specific_territories = get_experts_with_specific_territories(antenne_insee_codes, institution_subject)

        experts_without_specific_territories.each{ |expert| subject_hash[expert.insee_code] << { expert_id: expert.id, users_ids: expert.users.ids } }
        experts_with_specific_territories.each{ |expert| subject_hash[expert.insee_code] << { expert_id: expert.id, users_ids: expert.users.ids } }
        register_coverage(institution_subject, subject_hash)
      end
    end

    private

    def get_experts_without_specific_territories(insee_codes, institution_subject)
      with_custom_communes_subquery = institution_subject.not_deleted_experts.with_custom_communes

      institution_subject.not_deleted_experts
        .where.not(id: with_custom_communes_subquery)
        .select('experts.id, experts.antenne_id, communes.insee_code AS insee_code')
        .joins(antenne: :communes)
        .where(antenne_id: all_potential_antennes_ids)
        .where(communes: { insee_code: insee_codes })
    end

    def get_experts_with_specific_territories(insee_codes, institution_subject)
      institution_subject.not_deleted_experts
        .select('experts.id, experts.antenne_id, communes.insee_code AS insee_code')
        .joins(:communes)
        .where(antenne_id: all_potential_antennes_ids)
        .where(communes: { insee_code: insee_codes })
    end

    def register_coverage(institution_subject, subject_hash)
      if subject_hash.values.all?([])
        no_expert(institution_subject)
      elsif subject_hash.values.any?([])
        missing_insee_codes(institution_subject, subject_hash)
      elsif subject_hash.values.any?{ |a| a.uniq.size > 1 }
        extra_insee_codes(institution_subject, subject_hash)
      elsif subject_hash.values.flatten.pluck(:users_ids).all?([])
        no_user(institution_subject, subject_hash)
      else
        good_coverage(institution_subject, subject_hash)
      end
    end

    def good_coverage(institution_subject, code_experts_users_hash)
      all_experts = all_experts_ids(code_experts_users_hash)
      get_rc(institution_subject).update(
        coverage: get_coverage(all_experts),
        anomalie: :no_anomalie,
        anomalie_details: nil
      )
    end

    #- que des experts avec communes, et somme des communes < antenne.communes
    #- /!\ et pas d'expert global sur le sujet
    #- /!\ et pas d'expert de l'antenne ou de la région sur le sujet sans code commune
    def missing_insee_codes(institution_subject, code_experts_users_hash)
      missing_codes = code_experts_users_hash.select{ |k,v| v.empty? }.keys
      all_experts = all_experts_ids(code_experts_users_hash)
      get_rc(institution_subject).update(
        coverage: get_coverage(all_experts),
        anomalie: :missing_insee_codes,
        anomalie_details: {
          missing_insee_codes: missing_codes,
        }
      )
    end

    #- + d'un expert sans commune
    #- des experts avec communes + au moins un expert sans commune
    #- que des experts avec communes, et sommes des communes > antenne.communes
    def extra_insee_codes(institution_subject, code_experts_users_hash)
      extra_objects = code_experts_users_hash.select{ |k,v| v.size > 1 }
      extra_codes = extra_objects.keys
      extra_experts = all_experts_ids(extra_objects)
      all_experts = all_experts_ids(code_experts_users_hash)
      get_rc(institution_subject).update(
        coverage: get_coverage(all_experts),
        anomalie: :extra_insee_codes,
        anomalie_details: {
          extra_insee_codes: extra_codes,
          experts: extra_experts
        }
      )
    end

    def no_expert(institution_subject)
      get_rc(institution_subject).update(
        coverage: nil,
        anomalie: :no_expert,
        anomalie_details: nil
      )
    end

    def no_user(institution_subject, code_experts_users_hash)
      all_experts = all_experts_ids(code_experts_users_hash)
      get_rc(institution_subject).update(
        coverage: get_coverage(all_experts),
        anomalie: :no_user,
        anomalie_details: {
          experts: all_experts
        }
      )
    end

    def get_rc(institution_subject)
      ReferencementCoverage
        .where(antenne: @antenne, institution_subject: institution_subject)
        .first_or_initialize
    end

    def get_coverage(experts_ids)
      expert_antenne_ids = Expert.where(id: experts_ids).pluck(:antenne_id).uniq
      if expert_antenne_ids == [@antenne.id]
        @antenne.local? ? :local : :regional
      elsif expert_antenne_ids.include?(@antenne.id)
        :mixte
      else
        @antenne.local? ? :regional : :local
      end
    end

    def all_potential_antennes_ids
      @all_potential_antennes ||= [
        @antenne.id,
        @antenne&.regional_antenne&.id,
        @antenne.institution.antennes.territorial_level_national.pluck(:id),
        @antenne&.territorial_antennes&.pluck(:id)
      ].compact.flatten
    end

    def all_experts_ids(code_experts_users_hash)
      code_experts_users_hash.values.flatten.uniq.pluck(:expert_id)
    end
  end
end
