module Stats::Needs
  class DoneNotReachable
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

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

    def secondary_count
      filtered_main_query.status_done_not_reachable.size
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
