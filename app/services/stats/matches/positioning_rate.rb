module Stats::Matches
  class PositioningRate
    include ::Stats::BaseStats
    include ::Stats::FiltersStats
    include ::Stats::TwoRatesStats

    def main_query
      Match.sent.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      filtered_matches(query)
    end

    def build_series
      query = filtered_main_query
      @positioning, @not_positioning = [], []
      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @positioning.push(month_query.not_status_quo.count)
        @not_positioning.push(month_query.status_quo.count)
      end

      as_series(@positioning, @not_positioning)
    end

    def subtitle
      I18n.t('stats.series.positioning_rate.subtitle')
    end

    def colors
      matches_colors
    end

    private

    def as_series(positioning, not_positioning)
      [
        {
          name: I18n.t('stats.not_positioning'),
          data: not_positioning
        },
        {
          name: I18n.t('stats.positioning'),
          data: positioning
        }
      ]
    end
  end
end
