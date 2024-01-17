module Stats::Solicitations
  class Completed
    include ::Stats::BaseStats

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date).distinct
    end

    def filtered(query)
      Stats::Filters::Solicitations.new(query, self).call
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('stats.series.solicitations_completed.series')
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
      I18n.t('stats.series.solicitations_completed.subtitle_html')
    end

    def date_group_attribute
      'completed_at'
    end

    def grouped_by_month(query)
      # Ici les mois sont en UTC
      query.group("DATE_TRUNC('month', #{ActiveRecord::Base::sanitize_sql(query.model.name.pluralize)}.completed_at)")
    end
  end
end
