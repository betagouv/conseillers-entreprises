module Stats::Needs::Concerns::Themes
  include Stats::Needs::Base

  def main_query
    needs_themes_base_scope
      .joins(:advisor, subject: :theme)
  end

  def needs_themes_base_scope
    needs_base_scope
  end

  def date_group_attribute
    :created_at
  end

  def category_group_attribute
    'themes.label'
  end

  def category_order_attribute
    'themes.interview_sort_order'
  end

  def build_series
    result = super
    # regroupe les themes issus de la coopération si @detailed_graphs est à false
    cooperation_label = I18n.t('activerecord.attributes.theme.stats_label.cooperation')
    result << { name: cooperation_label, data: Array.new(result.first[:data].size, 0) }
    result.map do |item|
      next if item[:name] == cooperation_label
      label = Theme.stats_label(item[:name], @detailed_graphs)
      if label != item[:name]
        result.last[:data] = result.last[:data].zip(item[:data]).map { |a, b| a + b }
        item[:data].map! { |x| x = 0 }
      end
      item
    end
    result.reject { |item| item[:data].all?(0) }
  end

  def filtered(query)
    Stats::Filters::Needs.new(query, self).call
  end

  def subtitle
    I18n.t('stats.series.needs_themes_all.subtitle')
  end

  def count # rubocop:disable Naming/PredicateMethod
    false
  end

  def colors
    %w[#62e0d3 #2D908F #f3dd68 #e78112 #F45A5B #9f3cca #F15C80 #A8FF96 #946c47 #64609b #7a7a7a #CF162B]
  end
end
