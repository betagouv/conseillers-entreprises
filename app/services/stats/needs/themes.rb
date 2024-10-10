module Stats::Needs
  class Themes
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .joins(:advisor)
        .joins(subject: :theme)
    end

    def build_series
      query = filtered_main_query

      results = Theme.order(interview_sort_order: :asc).each_with_object({}) do |theme, hash|
        hash_count = hash[theme.stats_label] || {}
        new_count = query.where(subject: { theme_id: theme.id }).group("DATE_TRUNC('month', needs.created_at)").count
        hash[theme.stats_label] = new_count.merge(hash_count) { |key, old, new| old + new }
      end.reject{ |k,v| v.empty? }

      as_series(results)
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    def subtitle
      I18n.t('stats.series.needs_themes.subtitle')
    end

    def count
      false
    end

    def colors
      %w[#62e0d3 #2D908F #f3dd68 #e78112 #F45A5B #9f3cca #F15C80 #A8FF96 #946c47 #64609b #7a7a7a #CF162B]
    end
  end
end
