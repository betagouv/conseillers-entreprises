module Stats::Matches
  # Taux de mises en relation sans aide disponible sur la totalité des mises en relations transmises
  class DoneNoHelpRateStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Match.sent.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      filtered_matches(query)
    end

    def build_series
      # query = main_query
      # query = filtered(query)
      @done_no_help = []
      @other_status = []

      search_range_by_month.each do |range|
        # month_query = query.created_between(range.first, range.last)
        month_query = filtered_main_query.created_between(range.first, range.last)
        @done_no_help.push(month_query.status_done_no_help.count)
        @other_status.push(month_query.not_status_done_no_help.count)
      end

      as_series(@done_no_help, @other_status)
    end

    def count
      build_series
      percentage_two_numbers(@done_no_help, @other_status)
    end

    def secondary_count
      @done_no_help.sum
    end

    def subtitle
      I18n.t('stats.series.done_no_help_rate_stats.subtitle')
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
