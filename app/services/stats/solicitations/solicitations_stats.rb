module Stats::Solicitations
  class SolicitationsStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date)
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

    def subtitle
      I18n.t('stats.series.solicitations.subtitle_html')
    end

    def date_group_attribute
      'completed_at'
    end

    def grouped_by_month(query)
      # Ici les mois sont en UTC
      query.group("DATE_TRUNC('month', #{query.model.name.pluralize}.completed_at)")
    end
  end
end
