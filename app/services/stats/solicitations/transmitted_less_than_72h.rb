module Stats::Solicitations
  class TransmittedLessThan72h
    include ::Stats::BaseStats

    def main_query
      Solicitation.joins(diagnosis: :needs).status_processed.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Solicitations.new(query, self).call
    end

    def build_series
      query = main_query
      query = filtered(query)
      @less_than_72h = []
      @more_than_72h = []

      search_range_by_month.each do |range|
        grouped_result = group_by_date_in_range(query, range)
        @less_than_72h.push(grouped_result[true]&.size || 0)
        @more_than_72h.push(grouped_result[false]&.size || 0)
      end

      as_series(@less_than_72h, @more_than_72h)
    end

    def group_by_date_in_range(query, range)
      query_range = query.created_between(range.first, range.last)
      group_by_date(query_range)
    end

    def group_by_date(query)
      query.preload(:diagnosis).group_by do |solicitation|
        solicitation.transmitted_at&.between?(solicitation.created_at, solicitation.created_at + 3.days)
      end
    end

    def count
      series
      percentage_two_numbers(@less_than_72h, @more_than_72h)
    end

    private

    def as_series(less_than_72h, more_than_72h)
      [
        {
          name: I18n.t('stats.more_than_72h'),
          data: more_than_72h
        },
        {
          name: I18n.t('stats.less_than_72h'),
          data: less_than_72h
        }
      ]
    end
  end
end
