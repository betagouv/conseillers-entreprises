class UpdateAntenneHierarchyJob
  include Sidekiq::Job
  # Updated when changed : add/remove communes
  def perform(antenne_id)
    current_antenne = Antenne.find(antenne_id)
    institution_id = current_antenne.institution_id

    if current_antenne.national?
      regional_antennes = Antenne.not_deleted.where(institution: current_antenne.institution, territorial_level: Antenne.territorial_levels[:regional])
      regional_antennes.update_all(parent_antenne_id: current_antenne.id)
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
    institution_id = antenne.institution_id
    commune_ids = antenne.commune_ids
    Antenne.not_deleted.where(institution_id: institution_id, territorial_level: targeted_territorial_level)
      .left_joins(:communes, :experts)
      .where(communes: { id: commune_ids })
      .or(Antenne.not_deleted.where(institution_id: institution_id, territorial_level: targeted_territorial_level).where(experts: { is_global_zone: true }))
      .distinct
  end
end
