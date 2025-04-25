class CoverageService
  def initialize(institution_subject, grouped_experts)
    @institution_subject = institution_subject
    @grouped_experts = grouped_experts
    @antennes = @grouped_experts.keys
  end

  def call
    antennes_insee_codes = @antennes.map(&:insee_codes).flatten.uniq

    experts_and_users_by_insee_code = antennes_insee_codes.index_with { [] }
    experts_without_specific_territories = get_experts_without_specific_territories(antennes_insee_codes, @institution_subject)
    experts_with_specific_territories = get_experts_with_specific_territories(antennes_insee_codes, @institution_subject)

    experts_without_specific_territories.each do |expert|
      expert.antenne.insee_codes.each do |insee_code|
        experts_and_users_by_insee_code[insee_code] << { expert_id: expert.id, users_ids: expert.users.ids }
      end
    end
    experts_with_specific_territories.each do |expert|
      expert.insee_codes.each do |insee_code|
        experts_and_users_by_insee_code[insee_code] << { expert_id: expert.id, users_ids: expert.users.ids }
      end
    end
    check_coverage(experts_and_users_by_insee_code)
  end

  private

  def get_experts_without_specific_territories(insee_codes, institution_subject)
    institution_subject.not_deleted_experts
      .without_territorial_zones
      .where(antenne_id: all_potential_antennes_ids)
      .select { |expert| (expert.antenne.insee_codes & insee_codes).any? }
  end

  def get_experts_with_specific_territories(insee_codes, institution_subject)
    institution_subject.not_deleted_experts
      .with_territorial_zones
      .where(antenne_id: all_potential_antennes_ids)
      .select { |expert| (expert.insee_codes & insee_codes).any? }
  end

  def all_potential_antennes_ids
    @all_potential_antennes ||= @antennes.map do |antenne|
      [
        antenne.id,
        antenne&.regional_antenne&.id,
        antenne.institution.antennes.territorial_level_national.pluck(:id),
        antenne&.territorial_antennes&.pluck(:id)
      ]
    end.compact.flatten
  end

  def check_coverage(experts_and_users_by_insee_code)
    if @institution_subject.subject.territories.any? &&
      (@institution_subject.subject.territories & @antenne.regions).empty?
      good_coverage(experts_and_users_by_insee_code)
    elsif experts_and_users_by_insee_code.values.all?([])
      no_expert
    elsif experts_and_users_by_insee_code.values.any?([])
      missing_insee_codes(experts_and_users_by_insee_code)
    elsif experts_and_users_by_insee_code.values.any?{ |a| a.uniq.size > 1 }
      extra_insee_codes(experts_and_users_by_insee_code)
    elsif experts_and_users_by_insee_code.values.flatten.pluck(:users_ids).all?([])
      no_user(experts_and_users_by_insee_code)
    else
      good_coverage(experts_and_users_by_insee_code)
    end
  end

  def good_coverage(code_experts_users_hash)
    all_experts = all_experts_ids(code_experts_users_hash)
    {
      institution_subject_id: @institution_subject.id,
      coverage: get_coverage(all_experts),
      anomalie: :no_anomalie,
      anomalie_details: nil
    }
  end

  # - que des experts avec codes insee, et somme des codes insee < antenne.codes_insee
  # - /!\ et pas d'expert global sur le sujet
  # - /!\ et pas d'expert de l'antenne ou de la région sur le sujet sans code insee
  def missing_insee_codes(code_experts_users_hash)
    missing_codes = code_experts_users_hash.select{ |k,v| v.empty? }.keys
    all_experts = all_experts_ids(code_experts_users_hash)
    {
      institution_subject_id: @institution_subject.id,
      coverage: get_coverage(all_experts),
      anomalie: :missing_insee_codes,
      anomalie_details: {
        missing_insee_codes: missing_codes,
      }
    }
  end

  # - + d'un expert sans code insee
  # - des experts avec tz + au moins un expert sans code insee
  # - que des experts avec tz, et sommes des codes insee > antenne.codes_insee
  def extra_insee_codes(code_experts_users_hash)
    extra_objects = code_experts_users_hash.select{ |k,v| v.size > 1 }
    extra_codes = extra_objects.keys
    extra_experts = all_experts_ids(extra_objects)
    all_experts = all_experts_ids(code_experts_users_hash)
    {
      institution_subject_id: @institution_subject.id,
      coverage: get_coverage(all_experts),
      anomalie: :extra_insee_codes,
      anomalie_details: {
        extra_insee_codes: extra_codes,
        experts: extra_experts
      }
    }
  end

  def no_expert
    {
      institution_subject_id: @institution_subject.id,
      coverage: nil,
      anomalie: :no_expert,
      anomalie_details: nil
    }
  end

  def no_user(code_experts_users_hash)
    all_experts = all_experts_ids(code_experts_users_hash)
    {
      institution_subject_id: @institution_subject.id,
      coverage: get_coverage(all_experts),
      anomalie: :no_user,
      anomalie_details: {
        experts: all_experts
      }
    }
  end

  def get_coverage(experts_ids)
    # TODO revoir cette methode
    expert_antenne_ids = Expert.where(id: experts_ids).pluck(:antenne_id).uniq
    if expert_antenne_ids == @antennes.map(&:id)
      if @antennes.map(&:territorial_level).uniq.size == 1
        @antennes.first.territorial_level.to_sym
      else
        :mixte
      end
    elsif expert_antenne_ids.include?(@antennes.map(&:id))
      :mixte
    else
      if @antennes.map(&:territorial_level).uniq.size == 1
        @antennes.first.territorial_level.to_sym
      else
        :mixte
      end
    end
  end

  def all_experts_ids(code_experts_users_hash)
    code_experts_users_hash.values.flatten.uniq.pluck(:expert_id)
  end
end
