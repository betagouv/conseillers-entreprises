module Stats::Needs
  class Quo
    include Stats::Needs::Base

    def build_series
      query = filtered_main_query

      @needs_quo = []
      @needs_other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        needs_quo_query = month_query.where(status: :quo)
        needs_other_status_query = month_query.where.not(status: :quo)
        @needs_quo.push(needs_quo_query.count)
        @needs_other_status.push(needs_other_status_query.count)
      end

      as_series(@needs_quo, @needs_other_status)
    end

    def count
      series
      percentage_two_numbers(@needs_quo, @needs_other_status)
    end

    def secondary_count
      @secondary_count ||= filtered_main_query.status_quo.size
    end

    private

    def as_series(needs_quo, needs_other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_other_status
        },
        {
          name: I18n.t('stats.status_quo'),
          data: needs_quo
        }
      ]
    end
  end
end
