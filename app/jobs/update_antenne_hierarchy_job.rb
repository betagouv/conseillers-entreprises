class UpdateAntenneHierarchyJob
  include Sidekiq::Job
  # Updated when changed : add/remove communes
  def perform(antenne_id)
    current_antenne = Antenne.find_by(id: antenne_id)
    return unless current_antenne

    if current_antenne.national?
      # On prend les antennes régionales
      # Et les antennes locales qui n'ont pas d'antennes régionales
      regional_antennes = Antenne.not_deleted.where(institution: current_antenne.institution, territorial_level: :regional)
      regional_antennes.update_all(parent_antenne_id: current_antenne.id)
      local_antennes_with_regional_ids = regional_antennes.flat_map { |ra| get_associated_antennes(:local, ra).ids }
      local_antennes_without_regional = Antenne.where(territorial_level: :local, institution: current_antenne.institution)
                                                     .where.not(id: local_antennes_with_regional_ids.flatten)
      local_antennes_without_regional.update_all(parent_antenne_id: current_antenne.id)
    elsif current_antenne.regional?
      territorial_antennes = get_associated_antennes(Antenne.territorial_levels[:local], current_antenne)
      territorial_antennes.update_all(parent_antenne_id: current_antenne.id)
      national_antenne = Antenne.not_deleted.where(institution_id: current_antenne.institution_id, territorial_level: :national).first
      current_antenne.update(parent_antenne: national_antenne)
    else # antenne locale
      regional_antenne = get_associated_antennes(Antenne.territorial_levels[:regional], current_antenne)&.first
      current_antenne.update(parent_antenne: regional_antenne)
    end
  end

  private

  def get_associated_antennes(targeted_territorial_level, antenne)
    Antenne.not_deleted.where(institution_id: antenne.institution_id, territorial_level: targeted_territorial_level)
      .left_joins(:communes, :experts)
      .where(communes: { id: antenne.commune_ids })
      .or(Antenne.not_deleted.where(institution_id: antenne.institution_id, territorial_level: targeted_territorial_level)
                      .where(experts: { is_global_zone: true }))
      .distinct
  end
end
