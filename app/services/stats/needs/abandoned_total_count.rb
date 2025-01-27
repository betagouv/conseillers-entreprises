module Stats::Needs
  class AbandonedTotalCount
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
    end

    def build_series
      @abandoned_needs = []
      @not_abandoned_needs = []

      search_range_by_month.each do |range|
        @abandoned_needs << filtered_main_query.created_between(range.first, range.last).with_action(:abandon).count
        @not_abandoned_needs << filtered_main_query.created_between(range.first, range.last).without_action(:abandon).count
      end

      as_series(@abandoned_needs, @not_abandoned_needs)
    end

    def count
      series
      percentage_two_numbers(@abandoned_needs, @not_abandoned_needs)
    end

    def secondary_count
      filtered_main_query.with_action(:abandon).size
    end

    def subtitle
      I18n.t('stats.series.needs_abandoned_total_count.subtitle')
    end

    def as_series(abandoned_needs, not_abandoned_needs)
      [
        {
          name: I18n.t('stats.series.needs_abandoned_total_count.other_needs'),
          data: not_abandoned_needs
        },
        {
          name: I18n.t('stats.series.needs_abandoned_total_count.abandoned_needs'),
          data: abandoned_needs
        }
      ]
    end
  end
end
