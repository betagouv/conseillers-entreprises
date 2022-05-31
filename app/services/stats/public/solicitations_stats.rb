module Stats::Public
  class SolicitationsStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Solicitation.step_complete.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      filtered_solicitations(query)
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('stats.series.solicitations.series')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def chart
      'stats-chart'
    end
  end
end
