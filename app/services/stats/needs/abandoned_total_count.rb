module Stats::Needs
  class AbandonedTotalCount
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .with_action(:abandon)
    end

    def category_name(category)
      I18n.t('stats.series.needs_abandoned_total_count.series')
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    def build_series
      @needs = []

      search_range_by_month.each do |range|
        @needs << filtered_main_query.created_between(range.first, range.last).count
      end

      as_series(@needs)
    end

    def count
      total = filtered(needs_base_scope).size
      total == 0 ? "0" : "#{(secondary_count * 100).fdiv(total).round}%"
    end

    def secondary_count
      filtered(main_query).size
    end

    def subtitle
      I18n.t('stats.series.needs_abandoned_total_count.subtitle')
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def chart
      'column-chart'
    end

    def as_series(needs)
      [
        {
          name: I18n.t('stats.series.needs_abandoned_total_count.series'),
          data: needs
        }
      ]
    end
  end
end
