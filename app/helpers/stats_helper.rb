module StatsHelper
  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end

  def invoke_stats(name, params)
    graph = constantize_chart_name(name)
    graph.new(params)
  end

  def build_manager_antennes_collection(user)
    manager_antennes = manager_antennes_included_regionals(user)
    antennes_collection = antennes_collection_hash(Antenne.with_experts_subjects.not_deleted, manager_antennes)
    add_locals_antennes(antennes_collection, manager_antennes)
  end

  def build_institution_antennes_collection(institution)
    institution_antennes = institution.antennes.not_deleted
    antennes_collection = antennes_collection_hash(institution_antennes, institution_antennes)

    add_locals_antennes(antennes_collection, institution_antennes)
  end

  def stats_count(count)
    number_with_delimiter(count, locale: :fr, delimiter: ' ')
  end

  private

  def antennes_collection_hash(base_antennes, looking_for_antennes)
    base_antennes
      .where(id: [looking_for_antennes.ids, looking_for_antennes.map { |a| a.territorial_antennes.pluck(:id) }].flatten)
      .map { |a| { name: a.name, id: a.id, territorial_level: Antenne::TERRITORIAL_ORDER[a.territorial_level.to_sym] } }
  end

  def constantize_chart_name(name)
    name_splitted = name.split('_')
    category = name_splitted.first.capitalize
    graph = name_splitted[1..].map(&:capitalize).join
    "Stats::#{category}::#{graph}".constantize
  end

  def add_locals_antennes(antennes_collection, recipient_antennes)
    recipient_antennes.includes(:child_antennes).find_each do |antenne|
      next if antenne.local? || antenne.territorial_antennes.empty?
      # Pour les antennes régionales et nationales on affiche uniquement les stats agglomérés des antennes locales
      antennes_collection.delete_if { |a| a[:id] == antenne.id }
      antennes_collection << { name: antenne.name, id: "#{antenne[:id]}#{t('helpers.stats_helper.with_locales')}", territorial_level: Antenne::TERRITORIAL_ORDER[antenne.territorial_level.to_sym] }
    end
    antennes_collection.sort_by { |a| [a[:territorial_level], a[:name]] }
  end

  def manager_antennes_included_regionals(user)
    antennes_ids = user.managed_antennes.ids
    user.managed_antennes.territorial_level_national.each do |antenne|
      antennes_ids << Antenne.where(institution: antenne.institution, territorial_level: :regional).not_deleted.ids
    end
    Antenne.where(id: antennes_ids.flatten)
  end
end
