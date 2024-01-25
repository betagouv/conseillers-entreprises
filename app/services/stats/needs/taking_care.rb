module Stats::Needs
  class TakingCare
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
        .joins(:diagnosis).merge(Diagnosis.from_solicitation)
        .where(created_at: @start_date..@end_date)
    end

    def build_series
      query = filtered_main_query

      @needs_taking_care = []
      @needs_other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        needs_taking_care_query = month_query.where(status: :taking_care)
        needs_other_status_query = month_query.where.not(status: :taking_care)
        @needs_taking_care.push(needs_taking_care_query.count)
        @needs_other_status.push(needs_other_status_query.count)
      end

      as_series(@needs_taking_care, @needs_other_status)
    end

    def count
      build_series
      percentage_two_numbers(@needs_taking_care, @needs_other_status)
    end

    def filtered_main_query
      Stats::Filters::Needs.new(main_query, self).call
    end

    def secondary_count
      filtered_main_query.status_taking_care.size
    end

    private

    def as_series(needs_taking_care, needs_other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_other_status
        },
        {
          name: I18n.t('stats.status_taking_care'),
          data: needs_taking_care
        }
      ]
    end
  end
end
