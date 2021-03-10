module Stats::Public
  class TakingCareTimeStats
    include ::Stats::BaseStats

    def main_query
      Solicitation
        .joins(diagnosis: [needs: :matches])
        .merge(Need.where.not(status: [:diagnosis_not_complete, :quo]))
        .distinct
    end

    def group_by_date(query)
      query.group_by do |solicitation|
        solicitation.matches.pluck(:taken_care_of_at).compact.min&.between?(solicitation.created_at, solicitation.created_at + 5.days)
      end
    end

    def group_by_date_in_range(query, range)
      query_range = query.created_between(range.first, range.last)
      group_by_date(query_range)
    end

    def taken_care_before(query)
      return [] if query[true].nil?
      query[true].group_by_month(&:created_at).map { |_, v| v.size }
    end

    def taken_care_after(query)
      return [] if query[false].nil?
      query[false].group_by_month(&:created_at).map { |_, v| v.size }
    end

    def filtered(query)
      if territory.present?
        query.where!(diagnosis: territory.diagnoses)
      end
      if @start_date.present?
        query.where!("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @taken_care_before = []
      @taken_care_after = []

      search_range_by_month.each do |range|
        grouped_result = group_by_date_in_range(query, range)
        @taken_care_before.push(grouped_result[true]&.size || 0)
        @taken_care_after.push(grouped_result[false]&.size || 0)
      end

      as_series(@taken_care_before, @taken_care_after)
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def count
      build_series
      percentage_two_numbers(@taken_care_before, @taken_care_after)
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
