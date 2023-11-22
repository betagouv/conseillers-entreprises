module Stats::Matches
  # Taux de mises en relation sans aide disponible sur la totalité des mises en relations transmises
  class DoneNoHelp
    include ::Stats::BaseStats
    include ::Stats::FiltersStats
    include ::Stats::TwoRatesStats

    def main_query
      Match.sent.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Matches.new(query).call
    end

    def build_series
      query = filtered_main_query
      @done_no_help = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @done_no_help.push(month_query.status_done_no_help.count)
        @other_status.push(month_query.not_status_done_no_help.count)
      end
      as_series(@done_no_help, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_done_no_help.subtitle')
    end

    def colors
      matches_colors
    end

    private

    def as_series(done_no_help, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.done_no_help_status'),
          data: done_no_help
        }
      ]
    end
  end
end
