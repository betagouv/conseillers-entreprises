module Stats::Needs
  class Done
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.joins(:diagnosis)
        .merge(Diagnosis.from_solicitation.completed)
        .where(created_at: @start_date..@end_date)
    end

    def build_series
      query = filtered_main_query

      @needs_done = []
      @needs_other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        needs_done_query = month_query.where(status: :done)
        needs_other_status_query = month_query.where.not(status: :done)
        @needs_done.push(needs_done_query.count)
        @needs_other_status.push(needs_other_status_query.count)
      end

      as_series(@needs_done, @needs_other_status)
    end

    def count
      build_series
      percentage_two_numbers(@needs_done, @needs_other_status)
    end

    def filtered_main_query
      Stats::Filters::Needs.new(main_query).call
    end

    def secondary_count
      filtered_main_query.status_done.size
    end

    def subtitle
      I18n.t('stats.series.needs_done.subtitle')
    end

    private

    def as_series(needs_done, needs_other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_other_status
        },
        {
          name: I18n.t('stats.status_done'),
          data: needs_done
        }
      ]
    end
  end
end
