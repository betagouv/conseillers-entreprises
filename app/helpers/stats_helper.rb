module StatsHelper
  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end

  def invoke_stats(name, params)
    graph = constantize_chart_name(name)
    graph.new(params)
  end

  def build_manager_antennes_collection(user)
    antennes_collection = antennes_collection_hash(Antenne.with_experts_subjects.not_deleted, user.managed_antennes)

    add_locals_antennes(antennes_collection, user.managed_antennes)
  end

  def build_institution_antennes_collection(institution)
    institution_antennes = institution.antennes.not_deleted
    antennes_collection = antennes_collection_hash(institution_antennes, institution_antennes)

    add_locals_antennes(antennes_collection, institution_antennes)
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
      #  Ajoute la possibilité pour les antennes régionale d'avoir les stats agglomérés
      antennes_collection << { name: I18n.t('helpers.stats_helper.antenne_with_locales', name: antenne.name), id: "#{antenne[:id]}#{t('helpers.stats_helper.with_locales')}", territorial_level: Antenne::TERRITORIAL_ORDER[antenne.territorial_level.to_sym] }
    end
    antennes_collection.sort_by { |a| [a[:territorial_level], a[:name]] }
  end
end
