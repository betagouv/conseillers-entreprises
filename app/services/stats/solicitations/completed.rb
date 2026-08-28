module Stats::Solicitations
  class Completed
    include ::Stats::BaseStats

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Solicitations.new(query, self).call
    end

    def date_group_attribute
      'completed_at'
    end

    # Single series, one grouped query instead of one count per month.
    def build_series
      counts = grouped_by_month(filtered(main_query)).count
      by_month = counts.transform_keys { |month| month.to_date.beginning_of_month }
      [{ name: I18n.t('stats.series.solicitations_completed.series'), data: all_months.map { |month| by_month[month] || 0 } }]
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def chart
      'column-chart'
    end

    def subtitle
      I18n.t('stats.series.solicitations_completed.subtitle_html')
    end
  end
end
