module Stats::Needs
  class NeedsAbandonedStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = filtered_needs(query)

      @needs_archived = []
      @needs_not_archived = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        archived_query = month_query.archived(true)
        not_archived_query = month_query.archived(false)
        @needs_archived.push(archived_query.count)
        @needs_not_archived.push(not_archived_query.count)
      end

      as_series(@needs_archived, @needs_not_archived)
    end

    def count
      build_series
      percentage_two_numbers(@needs_archived, @needs_not_archived)
    end

    private

    def as_series(needs_archived, needs_not_archived)
      [
        {
          name: I18n.t('stats.not_archived'),
          data: needs_not_archived
        },
        {
          name: I18n.t('stats.archived'),
          data: needs_archived
        }
      ]
    end
  end
end
