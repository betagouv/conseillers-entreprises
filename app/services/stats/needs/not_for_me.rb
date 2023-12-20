module Stats::Needs
  class NotForMe
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_not_for_me = []
      @needs_other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        not_for_me_query = month_query.where(status: :not_for_me)
        other_status_query = month_query.where.not(status: :not_for_me)
        @needs_not_for_me.push(not_for_me_query.count)
        @needs_other_status.push(other_status_query.count)
      end

      as_series(@needs_not_for_me, @needs_other_status)
    end

    def count
      build_series
      percentage_two_numbers(@needs_not_for_me, @needs_other_status)
    end

    private

    def as_series(needs_not_for_me, needs_others_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_others_status
        },
        {
          name: I18n.t('stats.status_not_for_me'),
          data: needs_not_for_me
        }
      ]
    end
  end
end
