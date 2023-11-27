module StatsHelper
  def stats_filter_params
    params.permit(Stats::BaseStats::FILTER_PARAMS)
  end

  def invoke_stats(name, params)
    graph = constantize_chart_name(name)
    graph.new(params)
  end

  def build_antennes_collection(user)
    if user.is_manager? && user.managed_antennes.any?
      antennes = Antenne.where(id: [user.managed_antennes.ids, user.managed_antennes.map { |a| a.territorial_antennes.pluck(:id) }].flatten)
        .map { |a| { name: a.name, id: a.id } }
      user.managed_antennes.each do |antenne|
        next if antenne.local?
        #  Ajoute la possibilité pour les antennes régionale d'avoir les stats agglomérés
        antennes << { name: "#{antenne.name} + antennes locales", id: antenne.id }
      end
    else
      antennes = []
    end
    antennes.sort_by { |a| a[:name] }
  end

  private

  def constantize_chart_name(name)
    name_splitted = name.split('_')
    category = name_splitted.first.capitalize
    graph = name_splitted[1..].map(&:capitalize).join
    "Stats::#{category}::#{graph}".constantize
  end
end
