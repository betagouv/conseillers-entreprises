module Stats::Quality
  class NeedsDoneStats
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @needs_done = []
      @needs_not_done = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        needs_done_query = month_query.where(status: :done)
        needs_not_done_query = month_query.where.not(status: :done)
        @needs_done.push(needs_done_query.count)
        @needs_not_done.push(needs_not_done_query.count)
      end

      as_series(@needs_done, @needs_not_done)
    end

    def count
      build_series
      percentage_two_numbers(@needs_done, @needs_not_done)
    end

    private

    def as_series(needs_done, needs_not_done)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_not_done
        },
        {
          name: I18n.t('stats.status_done'),
          data: needs_done
        }
      ]
    end
  end
end
