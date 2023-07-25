module Stats::Public
  class TakingCareTimeStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Solicitation
        .step_complete
        .joins(diagnosis: [needs: :matches])
        .where(completed_at: @start_date..@end_date)
        .merge(Need.with_exchange)
        .distinct
    end

    def group_by_date(query)
      query.includes(:matches).group_by do |solicitation|
        solicitation.matches.pluck(:taken_care_of_at).compact.min&.between?(solicitation.completed_at, solicitation.completed_at + 5.days)
      end
    end

    def group_by_date_in_range(query, range)
      query_range = query.created_between(range.first, range.last)
      group_by_date(query_range)
    end

    def series
      @series ||= build_series
    end

    def build_series
      query = main_query
      query = filtered_needs(query)

      @taken_care_before = []
      @taken_care_after = []

      search_range_by_month.each do |range|
        grouped_result = group_by_date_in_range(query, range)
        @taken_care_before.push(grouped_result[true]&.size || 0)
        @taken_care_after.push(grouped_result[false]&.size || 0)
      end

      as_series(@taken_care_before, @taken_care_after)
    end

    def max_value
      100
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def count
      series
      @count ||= percentage_two_numbers(@taken_care_before, @taken_care_after)
    end

    private

    def as_series(taken_care_before, taken_care_after)
      [
        {
          name: I18n.t('stats.taken_care_after'),
            data: taken_care_after
        },
        {
          name: I18n.t('stats.taken_care_before'),
            data: taken_care_before
        }
      ]
    end
  end
end
