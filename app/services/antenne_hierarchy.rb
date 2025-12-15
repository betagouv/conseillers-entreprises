class AntenneHierarchy
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    if @antenne.national?
      # On prend les antennes régionales
      # Et les antennes locales qui n'ont pas d'antennes régionales
      regional_antennes = Antenne.not_deleted.where(institution: @antenne.institution, territorial_level: :regional)
      # Réinitialise d'abord toutes les relations régionales incorrectes
      clean_parent_antennes(@antenne.id, regional_antennes, :regional)
      regional_antennes.update_all(parent_antenne_id: @antenne.id)

      local_antennes_with_regional_ids = regional_antennes.flat_map { |ra| get_associated_antennes(:local, ra).ids }
      local_antennes_without_regional = Antenne.where(territorial_level: :local, institution: @antenne.institution)
        .where.not(id: local_antennes_with_regional_ids.flatten)
      # Réinitialise d'abord toutes les relations locales incorrectes
      clean_parent_antennes(@antenne.id, local_antennes_without_regional)
      local_antennes_without_regional.update_all(parent_antenne_id: @antenne.id)

    elsif @antenne.regional?
      # Va chercher les antennes locales et l'antenne nationale associées
      territorial_antennes = get_associated_antennes(Antenne.territorial_levels[:local], @antenne)
      # Réinitialise d'abord toutes les relations enfants incorrectes
      clean_parent_antennes(@antenne.id, territorial_antennes)
      # Puis met à jour les bonnes relations
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

  def clean_parent_antennes(antenne_id, antennes_to_keep, level = :local)
    Antenne.where(parent_antenne_id: antenne_id, territorial_level: level)
      .where.not(id: antennes_to_keep)
      .update_all(parent_antenne_id: nil)
  end

  def get_associated_antennes(targeted_territorial_level, antenne)
    base_relation = Antenne.not_deleted.where(institution_id: antenne.institution_id, territorial_level: targeted_territorial_level)
    antennes_with_territories_ids = base_relation.with_insee_codes(antenne.insee_codes).pluck(:id)
    global_zone_ids = base_relation.joins(:experts).where(experts: { is_global_zone: true }).pluck(:id)

    Antenne.where(id: (antennes_with_territories_ids + global_zone_ids))
  end
end
