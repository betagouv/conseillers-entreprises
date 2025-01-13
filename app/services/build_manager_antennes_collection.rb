class BuildManagerAntennesCollection
  def initialize(user)
    @user = user
  end

  def call
    manager_antennes = manager_antennes_included_regionals
    antennes_collection = antennes_collection_hash(Antenne.with_experts_subjects.not_deleted, manager_antennes)
    add_locals_antennes(antennes_collection, manager_antennes)
  end

  private

  def antennes_collection_hash(base_antennes, looking_for_antennes)
    base_antennes
      .where(id: [looking_for_antennes.ids, looking_for_antennes.map { |a| a.territorial_antennes.pluck(:id) }].flatten)
      .map { |a| { name: a.name, id: a.id, territorial_level: Antenne::TERRITORIAL_ORDER[a.territorial_level.to_sym] } }
  end

  def add_locals_antennes(antennes_collection, recipient_antennes)
    recipient_antennes.includes(:child_antennes).find_each do |antenne|
      next if antenne.local? || antenne.territorial_antennes.empty?
      # Pour les antennes régionales et nationales on affiche uniquement les stats agglomérés des antennes locales
      antennes_collection.delete_if { |a| a[:id] == antenne.id }
      antennes_collection << { name: antenne.name, id: "#{antenne[:id]}#{I18n.t('helpers.stats_helper.with_locales')}", territorial_level: Antenne::TERRITORIAL_ORDER[antenne.territorial_level.to_sym] }
    end
    antennes_collection.sort_by { |a| [a[:territorial_level], a[:name]] }
  end

  def manager_antennes_included_regionals
    antennes_ids = @user.managed_antennes.ids
    @user.managed_antennes.territorial_level_national.each do |antenne|
      antennes_ids << Antenne.where(institution: antenne.institution, territorial_level: :regional).not_deleted.ids
    end
    Antenne.where(id: antennes_ids.flatten)
  end
end
