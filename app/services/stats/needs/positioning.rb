module Stats::Needs
  class Positioning
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats

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
      I18n.t('stats.series.needs_positioning.subtitle')
    end

    def secondary_count
      @secondary_count ||= filtered_main_query.not_status_quo.size
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
