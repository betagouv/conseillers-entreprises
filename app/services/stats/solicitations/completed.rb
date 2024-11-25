module Stats::Solicitations
  class Completed
    include ::Stats::BaseStats

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = Stats::Filters::Solicitations.new(query, self).call

      @solicitations = []

      search_range_by_month.each do |range|
        month_query = query.where(completed_at: range.first..range.last)
        @solicitations.push(month_query.count)
      end

      as_series(@solicitations)
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

    private

    def as_series(solicitations)
      [
        {
          name: I18n.t('stats.series.solicitations_completed.series'),
          data: solicitations
        }
      ]
    end
  end
end
