module Stats::Needs
  class Abandoned
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = filtered_needs(query)

      @needs_abandonned = []
      @needs_not_abandonned = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        abandonned_query = month_query.with_action(:abandon)
        not_abandonned_query = month_query.without_action(:abandon)
        @needs_abandonned.push(abandonned_query.count)
        @needs_not_abandonned.push(not_abandonned_query.count)
      end

      as_series(@needs_abandonned, @needs_not_abandonned)
    end

    def count
      build_series
      percentage_two_numbers(@needs_abandonned, @needs_not_abandonned)
    end

    private

    def as_series(needs_abandonned, needs_not_abandonned)
      [
        {
          name: I18n.t('stats.not_abandonned'),
          data: needs_not_abandonned
        },
        {
          name: I18n.t('stats.abandonned'),
          data: needs_abandonned
        }
      ]
    end
  end
end
