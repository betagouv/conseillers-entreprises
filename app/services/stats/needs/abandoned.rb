module Stats::Needs
  class Abandoned
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query).call

      @needs_abandoned = []
      @needs_not_abandoned = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        abandoned_query = month_query.with_action(:abandon)
        not_abandoned_query = month_query.without_action(:abandon)
        @needs_abandoned.push(abandoned_query.count)
        @needs_not_abandoned.push(not_abandoned_query.count)
      end

      as_series(@needs_abandoned, @needs_not_abandoned)
    end

    def count
      build_series
      percentage_two_numbers(@needs_abandoned, @needs_not_abandoned)
    end

    private

    def as_series(needs_abandoned, needs_not_abandoned)
      [
        {
          name: I18n.t('stats.not_abandoned'),
          data: needs_not_abandoned
        },
        {
          name: I18n.t('stats.abandoned'),
          data: needs_abandoned
        }
      ]
    end
  end
end
