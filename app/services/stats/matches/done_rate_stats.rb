module Stats::Matches
  # Taux de mises en relation clôturées grâce à une aide proposée sur la totalité des mises en relation transmises
  class DoneRateStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Match.sent
    end

    def filtered(query)
      filtered_matches(query)
    end

    def build_series
      query = main_query
      query = filtered(query)

      @done_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @done_status.push(month_query.status_done.count)
        @other_status.push(month_query.not_status_done.count)
      end

      as_series(@done_status, @other_status)
    end

    def count
      build_series
      percentage_two_numbers(@done_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.done_rate_stats.subtitle')
    end

    private

    def as_series(done_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.done_status'),
          data: done_status
        }
      ]
    end
  end
end
