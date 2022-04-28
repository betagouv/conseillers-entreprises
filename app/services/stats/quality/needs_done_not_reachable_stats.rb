module Stats::Quality
  class NeedsDoneNotReachableStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = filtered_needs(query)

      @needs_done_not_reachable = []
      @needs_other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        done_not_reachable_query = month_query.where(status: :done_not_reachable)
        other_status_query = month_query.where.not(status: :done_not_reachable)
        @needs_done_not_reachable.push(done_not_reachable_query.count)
        @needs_other_status.push(other_status_query.count)
      end

      as_series(@needs_done_not_reachable, @needs_other_status)
    end

    def count
      build_series
      percentage_two_numbers(@needs_done_not_reachable, @needs_other_status)
    end

    private

    def as_series(needs_done_not_reachable, needs_other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_other_status
        },
        {
          name: I18n.t('stats.status_done_not_reachable'),
          data: needs_done_not_reachable
        }
      ]
    end
  end
end
