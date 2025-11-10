class CreateTerritorialCoverage
  def initialize(institution_subject, grouped_experts)
    @institution_subject = institution_subject
    @grouped_experts = grouped_experts
    @antennes = @grouped_experts.keys
    @antennes_insee_codes = @antennes.flat_map(&:insee_codes).uniq
    @all_potential_antennes_ids = compute_all_potential_antennes_ids
    @all_experts = gather_all_experts
  end

  def call
    return theme_outside_territories if theme_outside_territories?

    experts_and_users_by_insee_code = initialize_experts_and_users_by_insee_code
    global_experts_and_users = build_global_experts_and_users

    check_coverage(experts_and_users_by_insee_code, global_experts_and_users)
  end

  private

  def theme_outside_territories?
    @institution_subject.theme.territories.any? &&
      !@institution_subject.theme.insee_codes.intersect?(@antennes_insee_codes)
  end

  def gather_all_experts
    experts_without_specific_territories + experts_with_specific_territories + experts_with_global_zone
  end

  def initialize_experts_and_users_by_insee_code
    experts_and_users_by_insee_code = @antennes_insee_codes.index_with { [] }

    experts_and_users_by_insee_code = process_experts(experts_and_users_by_insee_code, experts_without_specific_territories, :antenne)

    process_experts(experts_and_users_by_insee_code, experts_with_specific_territories, :expert)
  end

  def build_global_experts_and_users
    experts_with_global_zone.map do |expert|
      { expert_id: expert.id, users_ids: expert.users.map(&:id) }
    end
  end

  def experts_without_specific_territories
    @experts_without_specific_territories ||= @institution_subject.not_deleted_experts
      .without_territorial_zones
      .includes(:users, antenne: :territorial_zones)
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

  def process_experts(experts_and_users_by_insee_code, experts, source_type)
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
    coverage_result = determine_coverage_status(experts_and_users_by_insee_code, experts_global_with_users)
    add_metadata_to_result(coverage_result)
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
    extra_experts = Expert.where(id: extra_experts_ids(extra_objects))
    {
      anomalie: :extra_insee_codes,
      anomalie_details: {
        experts: extra_experts,
        match_filters: get_match_filters(extra_experts),
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

  def get_match_filters(experts = nil)
    # Filter experts by provided IDs if specified, otherwise use all experts
    experts_to_check = experts || @all_experts
    expert_ids_to_check = experts_to_check.pluck(:id)
    antenne_ids_to_check = experts_to_check.pluck(:antenne_id).uniq

    experts_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Expert', filtrable_element_id: expert_ids_to_check).where(subjects: [@institution_subject.subject, nil])
    antennes_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Antenne', filtrable_element_id: antenne_ids_to_check).where(subjects: [@institution_subject.subject, nil])
    institution_match_filters = MatchFilter.left_joins(:subjects).where(filtrable_element_type: 'Institution', filtrable_element_id: @institution_subject.institution.id).where(subjects: [@institution_subject.subject, nil])
    {
      antenne: antennes_match_filters.map do |filter|
        types_labels = filter.filter_types.map { |type| I18n.t(type, scope: 'activerecord.attributes.match_filter') }
        "#{types_labels.join(', ')} - #{filter.filtrable_element}"
      end,
      expert: experts_match_filters.map do |filter|
        types_labels = filter.filter_types.map { |type| I18n.t(type, scope: 'activerecord.attributes.match_filter') }
        "#{types_labels.join(', ')} - #{filter.filtrable_element}"
      end,
      institution: institution_match_filters.map do |filter|
        types_labels = filter.filter_types.map { |type| I18n.t(type, scope: 'activerecord.attributes.match_filter') }
        "#{types_labels.join(', ')} - #{filter.filtrable_element}"
      end
    }
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

  def determine_coverage_status(experts_by_insee, global_experts)
    return good_coverage if theme_outside_covered_territories?(experts_by_insee)
    return no_expert if no_experts_available?(experts_by_insee, global_experts)
    return missing_insee_codes(experts_by_insee) if has_missing_coverage?(experts_by_insee)
    return no_user if has_experts_but_no_users?(experts_by_insee, global_experts)
    return extra_insee_codes(experts_by_insee) if has_duplicate_coverage?(experts_by_insee)

    good_coverage
  end

  def add_metadata_to_result(coverage_result)
    coverage_result.merge({
      coverage: get_coverage,
      institution_subject_id: @institution_subject.id,
      cooperations_details: format_cooperations_details,
    })
  end

  def theme_outside_covered_territories?(experts_by_insee)
    # Subject territories don't match antenne regions
    territories_mismatch = @institution_subject.subject.territories.any? &&
                          @antennes.any? &&
                          !subject_regions.intersect?(antenne_regions)

    # Theme has INSEE codes outside observed territories
    theme_codes_mismatch = @institution_subject.theme.insee_codes.present? &&
                          !@institution_subject.theme.insee_codes.intersect?(experts_by_insee.keys)

    territories_mismatch || theme_codes_mismatch
  end

  def no_experts_available?(experts_by_insee, global_experts)
    experts_by_insee.values.all?([]) && global_experts.pluck(:expert_id).empty?
  end

  def has_missing_coverage?(experts_by_insee)
    experts_by_insee.values.any?([])
  end

  def has_experts_but_no_users?(experts_by_insee, global_experts)
    local_experts_no_users = experts_by_insee.values.flatten.pluck(:users_ids).all?([])
    global_experts_no_users = global_experts.pluck(:users_ids).empty?

    local_experts_no_users && global_experts_no_users
  end

  def has_duplicate_coverage?(experts_by_insee)
    experts_by_insee.values.any? { |experts| experts.uniq.size > 1 }
  end

  def subject_regions
    @subject_regions ||= @institution_subject.subject.territories.flat_map(&:regions)
  end

  def antenne_regions
    @antenne_regions ||= @antennes.flat_map(&:regions)
  end
end
