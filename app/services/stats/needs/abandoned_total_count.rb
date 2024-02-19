module Stats::Needs
  class AbandonedTotalCount
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .with_action(:abandon)
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def category_name(category)
      I18n.t('stats.series.needs_abandoned_total_count.series')
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    def count
      total = filtered(Need.diagnosis_completed
                           .joins(:diagnosis).merge(Diagnosis.from_solicitation)
                           .where(created_at: @start_date..@end_date))
      total == 0 ? "0" : "#{(secondary_count * 100).fdiv(total.size).round}%"
    end

    def secondary_count
      filtered(main_query).size
    end

    def subtitle
      I18n.t('stats.series.needs_abandoned_total_count.subtitle')
    end

    def chart
      'stats-chart'
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end
  end
end
