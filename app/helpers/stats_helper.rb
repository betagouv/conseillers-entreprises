module StatsHelper
  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end

  def invoke_stats(name, params)
    graph = constantize_chart_name(name)
    graph.new(params)
  end

  def build_manager_antennes_collection(user)
    antennes_collection = Antenne.with_experts_subjects.not_deleted.where(id: [user.managed_antennes.ids, user.managed_antennes.map { |a| a.territorial_antennes.pluck(:id) }].flatten)
      .map { |a| { name: a.name, id: a.id } }

    add_locals_antennes(antennes_collection, user.managed_antennes)
  end

  def build_institution_antennes_collection(institution)
    antennes_collection = institution.antennes.not_deleted.where(id: [institution.antennes.not_deleted.ids, institution.antennes.not_deleted.map { |a| a.territorial_antennes.pluck(:id) }].flatten)
               .map { |a| { name: a.name, id: a.id } }

    add_locals_antennes(antennes_collection, institution.antennes.not_deleted)
  end

  def build_antennes_collection_for_select(antennes)
    antennes.map do |a|
      [a[:name], "#{a[:id]}#{a[:name].include?('locales') ? ' avec antennes locales' : ''}"]
    end
  end

  private

  def constantize_chart_name(name)
    name_splitted = name.split('_')
    category = name_splitted.first.capitalize
    graph = name_splitted[1..].map(&:capitalize).join
    "Stats::#{category}::#{graph}".constantize
  end

  def add_locals_antennes(antennes_collection, recipient_antennes)
    recipient_antennes.each do |antenne|
      next if antenne.local? || antenne.territorial_antennes.empty?
      #  Ajoute la possibilité pour les antennes régionale d'avoir les stats agglomérés
      antennes_collection << { name: I18n.t('helpers.stats_helper.antenne_with_locales', name: antenne.name), id: antenne.id }
    end
    antennes_collection.sort_by { |a| a[:name] }
  end
end
