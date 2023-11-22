module Stats::Matches
  # Taux de mises en relation en cours de prises en charge sur l’ensemble des mises en relation transmises
  class TakingCare
    include ::Stats::BaseStats
    include ::Stats::FiltersStats
    include ::Stats::TwoRatesStats

    def main_query
      Match.sent.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Matches.new(query).call
    end

    def build_series
      query = filtered_main_query
      @taking_care_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @taking_care_status.push(month_query.status_taking_care.count)
        @other_status.push(month_query.not_status_taking_care.count)
      end

      as_series(@taking_care_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_taking_care.subtitle')
    end

    def colors
      matches_colors
    end

    private

    def as_series(taking_care_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.taking_care_status'),
          data: taking_care_status
        }
      ]
    end
  end
end
