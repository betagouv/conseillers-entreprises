class CoverageService
  def initialize(institution_subject, grouped_experts)
    @institution_subject = institution_subject
    @grouped_experts = grouped_experts
    @antennes = @grouped_experts.keys
    @antennes_insee_codes = @antennes.flat_map(&:insee_codes).uniq
    @all_potential_antennes_ids = compute_all_potential_antennes_ids
    gather_all_experts
  end

  def call
    return theme_outside_territories if theme_outside_territories?(@antennes_insee_codes)

    experts_and_users_by_insee_code = initialize_experts_and_users_by_insee_code
    global_experts_and_users = build_global_experts_and_users

    check_coverage(experts_and_users_by_insee_code, global_experts_and_users)
  end

  private

  def theme_outside_territories?(antennes_insee_codes)
    @institution_subject.theme.territories.any? &&
      (@institution_subject.theme.insee_codes & antennes_insee_codes).empty?
  end

  def gather_all_experts
    @all_experts ||= begin
      experts_without_specific_territories + experts_with_specific_territories + experts_with_global_zone
    end
  end

  def initialize_experts_and_users_by_insee_code
    experts_and_users_by_insee_code = @antennes_insee_codes.index_with { [] }

    experts_and_users_by_insee_code = process_experts_optimized(experts_and_users_by_insee_code, experts_without_specific_territories, :antenne)

    process_experts_optimized(experts_and_users_by_insee_code, experts_with_specific_territories, :expert)
  end

  def build_global_experts_and_users
    experts_with_global_zone.map do |expert|
      { expert_id: expert.id, users_ids: expert.users.map(&:id) }
    end
  end

  def experts_without_specific_territories
    @experts_without_specific_territories ||= @institution_subject.not_deleted_experts
      .without_territorial_zones
      .includes(:users, :antenne)
      .where(antenne_id: @all_potential_antennes_ids)
      .select { |expert| expert.antenne.intersects_with_insee_codes?(@antennes_insee_codes) }
      .uniq
  end

  def experts_with_global_zone
    @experts_with_global_zone ||= @institution_subject.not_deleted_experts
      .with_global_zone
      .includes(:users)
      .where(antenne_id: @all_potential_antennes_ids)
      .distinct
  end

  def experts_with_specific_territories
    @experts_with_specific_territories ||= begin
      experts = @institution_subject.not_deleted_experts
        .with_territorial_zones
        .includes(:users, :territorial_zones)
        .where(antenne_id: @all_potential_antennes_ids)

      experts.select { |expert| expert.intersects_with_insee_codes?(@antennes_insee_codes) }.uniq
    end
  end

  private

  # Version optimisée de process_experts utilisant les relations hiérarchiques
  def process_experts_optimized(experts_and_users_by_insee_code, experts, source_type)
    # Préfère une structure temporaire et un Set pour améliorer la performance
    valid_insee_codes = experts_and_users_by_insee_code.keys
    
    experts.each do |expert|
      matching_insee_codes = case source_type
      when :antenne
        # Pour les experts sans zones spécifiques, calcule l'intersection avec l'antenne
        calculate_intersection_with_antenne(expert.antenne, valid_insee_codes)
      when :expert
        # Pour les experts avec zones spécifiques, calcule l'intersection avec l'expert
        calculate_intersection_with_expert(expert, valid_insee_codes)
      end
      
      # Ajoute l'expert à tous les codes INSEE qu'il couvre
      matching_insee_codes.each do |insee_code|
        experts_and_users_by_insee_code[insee_code] << { 
          expert_id: expert.id, 
          users_ids: expert.users.pluck(:id) 
        }
      end
    end

    experts_and_users_by_insee_code
  end

  def calculate_intersection_with_antenne(antenne, valid_insee_codes)
    antenne_insee_codes = antenne.insee_codes
    valid_insee_codes.select { |code| antenne_insee_codes.include?(code) }
  end

  def calculate_intersection_with_expert(expert, valid_insee_codes)
    expert_insee_codes = expert.insee_codes
    valid_insee_codes.select { |code| expert_insee_codes.include?(code) }
  end

  def compute_all_potential_antennes_ids
    @antennes.flat_map do |antenne|
      [
        antenne.id,
        antenne.regional_antenne&.id,
        antenne.institution.antennes.where(territorial_level: 'national').pluck(:id),
        antenne.territorial_antennes&.pluck(:id)
      ]
    end.compact.flatten.uniq
  end

  def all_potential_antennes_ids
    @all_potential_antennes_ids
  end

  def check_coverage(experts_and_users_by_insee_code, experts_global_with_users)
    # rubocop:disable Lint/DuplicateBranch
    coverage_hash = if (@institution_subject.subject.territories.any? && @antennes.any? &&
      (@institution_subject.subject.territories.flat_map(&:regions) & @antennes.flat_map(&:regions)).empty?) ||
      (@institution_subject.theme.insee_codes.present? && (@institution_subject.theme.insee_codes & experts_and_users_by_insee_code.keys).empty?) # Si le theme a des codes INSEE qui ne sont pas dans en dehors des territoires observés
      good_coverage
    elsif experts_and_users_by_insee_code.values.all?([]) &&
      experts_global_with_users.pluck(:expert_id).empty?
      no_expert
    elsif experts_and_users_by_insee_code.values.any?([])
      missing_insee_codes(experts_and_users_by_insee_code)
    elsif experts_and_users_by_insee_code.values.flatten.pluck(:users_ids).all?([]) &&
      experts_global_with_users.pluck(:users_ids).empty?
      no_user
    elsif experts_and_users_by_insee_code.values.any?{ |a| a.uniq.size > 1 }
      extra_insee_codes(experts_and_users_by_insee_code)
    else
      good_coverage
    end
    coverage_hash.merge({
      coverage: get_coverage,
                          institution_subject_id: @institution_subject.id,
                          cooperations_details: format_cooperations_details,
    })
    # rubocop:enable Lint/DuplicateBranch
  end

  def good_coverage
    {
      anomalie: :no_anomalie,
      anomalie_details: nil,
    }
  end

  # - que des experts avec codes insee, et somme des codes insee < antenne.codes_insee
  # - /!\ et pas d'expert global sur le sujet
  # - /!\ et pas d'expert de l'antenne ou de la région sur le sujet sans code insee
  def missing_insee_codes(code_experts_users_hash)
    missing_codes = code_experts_users_hash.select{ |_,v| v.empty? }.keys
    {
      anomalie: :missing_insee_codes,
      anomalie_details: {
        missing_insee_codes: format_territories(missing_codes),
      }
    }
  end

  # - + d'un expert sans code insee
  # - des experts avec tz + au moins un expert sans code insee
  # - que des experts avec tz, et sommes des codes insee > antenne.codes_insee
  def extra_insee_codes(code_experts_users_hash)
    extra_objects = code_experts_users_hash.select{ |_,v| v.size > 1 }
    extra_codes = extra_objects.keys
    extra_experts = extra_experts_ids(extra_objects)
    {
      anomalie: :extra_insee_codes,
      anomalie_details: {
        experts: extra_experts,
        match_filters: get_match_filters,
        extra_insee_codes: format_territories(extra_codes),
      }
    }
  end

  def no_expert
    {
      anomalie: :no_expert,
      anomalie_details: nil
    }
  end

  def no_user
    {
      anomalie: :no_user,
      anomalie_details: {
        experts: @all_experts,
      }
    }
  end

  def theme_outside_territories
    {
      anomalie: :theme_outside_territories,
      anomalie_details: nil
    }
  end

  def get_coverage
    return nil if @all_experts.empty?
    experts_antennes = @all_experts.map(&:antenne).uniq
    territorial_level = experts_antennes.pluck(:territorial_level).uniq
    if territorial_level.size == 1
      territorial_level.first.to_sym
    else
      :mixte
    end
  end

  def extra_experts_ids(code_experts_users_hash)
    code_experts_users_hash.values.flatten.uniq.pluck(:expert_id)
  end

  def format_territories(codes)
    DecoupageAdministratif::Search.new(codes).by_insee_codes.map do |zone_type, territory|
      {
        zone_type: zone_type,
        territories: territory.map do |t|
          {
            code: t.code,
            name: t.nom,
          }
        end
      }
    end
  end

  def get_match_filters
    experts_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Expert', filtrable_element_id: @all_experts.pluck(:id)).where(subjects: [@institution_subject.subject, nil])
    antennes_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Antenne', filtrable_element_id: @antennes.pluck(:id)).where(subjects: [@institution_subject.subject, nil])
    institution_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Institution', filtrable_element_id: @institution_subject.institution.id).where(subjects: [@institution_subject.subject, nil])
    {
      antenne: antennes_match_filters.map { |filter| "#{I18n.t(filter.filter_type, scope: 'activerecord.attributes.match_filter')} - #{filter.filtrable_element}" },
      expert: experts_match_filters.map { |filter| "#{I18n.t(filter.filter_type, scope: 'activerecord.attributes.match_filter')} - #{filter.filtrable_element}" },
      institution: institution_match_filters.map { |filter| "#{I18n.t(filter.filter_type, scope: 'activerecord.attributes.match_filter')} - #{filter.filtrable_element}" }
    }
  end

  def process_experts(experts_and_users_by_insee_code, experts)
    # Préfère une méthode avec une structure temporaire et un Set pour améliorer la performance de 9-10%
    valid_insee_codes = experts_and_users_by_insee_code.keys.to_set

    # Prépare une structure temporaire pour regrouper les experts par code INSEE
    temp_experts_by_insee = Hash.new { |h, k| h[k] = [] }

    experts.each do |expert|
      insee_codes = yield(expert)
      insee_codes.each do |insee_code|
        next unless valid_insee_codes.include?(insee_code)

        temp_experts_by_insee[insee_code] << { expert_id: expert.id, users_ids: expert.users.pluck(:id) }
      end
    end

    # Fusionner les données temporaires dans la structure principale
    temp_experts_by_insee.each do |insee_code, expert_data|
      experts_and_users_by_insee_code[insee_code].concat(expert_data)
    end

    experts_and_users_by_insee_code
  end

  def format_cooperations_details
    cooperations = get_cooperations
    if cooperations.empty?
      nil
    else
      {
        cooperations: cooperations,
        theme_territories: format_territories(@institution_subject.theme.insee_codes),
      }
    end
  end

  def get_cooperations
    @institution_subject.theme.cooperations.map do |cooperation|
      {
        id: cooperation.id,
        name: cooperation.name,
      }
    end
  end
end
