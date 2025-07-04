class AntenneHierarchy
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    if @antenne.national?
      # On prend les antennes régionales
      # Et les antennes locales qui n'ont pas d'antennes régionales
      regional_antennes = Antenne.not_deleted.where(institution: @antenne.institution, territorial_level: :regional)
      regional_antennes.update_all(parent_antenne_id: @antenne.id)
      local_antennes_with_regional_ids = regional_antennes.flat_map { |ra| get_associated_antennes(:local, ra).ids }
      local_antennes_without_regional = Antenne.where(territorial_level: :local, institution: @antenne.institution)
        .where.not(id: local_antennes_with_regional_ids.flatten)
      local_antennes_without_regional.update_all(parent_antenne_id: @antenne.id)
    elsif @antenne.regional?
      # Va chercher les antennes locales et l'antenne nationale associées
      territorial_antennes = get_associated_antennes(Antenne.territorial_levels[:local], @antenne)
      territorial_antennes.update_all(parent_antenne_id: @antenne.id)
      national_antenne = Antenne.not_deleted.where(institution_id: @antenne.institution_id, territorial_level: :national).first
      @antenne.update(parent_antenne: national_antenne)
    else # antenne locale
      # Va chercher l'antenne régionale associée
      regional_antenne = get_associated_antennes(Antenne.territorial_levels[:regional], @antenne)&.first
      @antenne.update(parent_antenne: regional_antenne)
    end
  end

  private

  def get_associated_antennes(targeted_territorial_level, antenne)
    antennes_with_territories = Antenne.not_deleted.where(institution_id: antenne.institution_id, territorial_level: targeted_territorial_level)
      .with_insee_codes((antenne.insee_codes))

    antenne_global_zone = Antenne.not_deleted.joins(:experts).where(institution_id: antenne.institution_id, territorial_level: targeted_territorial_level)
      .where(experts: { is_global_zone: true })
    Antenne.where(id: antennes_with_territories.pluck(:id) + antenne_global_zone.pluck(:id))
  end
end
