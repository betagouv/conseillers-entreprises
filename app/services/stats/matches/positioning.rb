module Stats::Matches
  class Positioning
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end

    def build_series
      query = filtered_main_query
      @positioning, @not_positioning = [], []
      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @positioning.push(month_query.not_status_quo.count)
        @not_positioning.push(month_query.status_quo.count)
      end

      as_series(@positioning, @not_positioning)
    end

    def subtitle
      I18n.t('stats.series.matches_positioning.subtitle')
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
