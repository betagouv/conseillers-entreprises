module Stats::Matches
  # Taux de mises en relation en cours de prises en charge sur l’ensemble des mises en relation transmises
  class TakingCareRateStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Match.sent
    end

    def filtered(query)
      filtered_matches(query)
    end

    def build_series
      query = main_query
      query = filtered(query)

      @tacking_care_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @tacking_care_status.push(month_query.status_taking_care.count)
        @other_status.push(month_query.not_status_taking_care.count)
      end

      as_series(@tacking_care_status, @other_status)
    end

    def count
      build_series
      percentage_two_numbers(@tacking_care_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.taking_care_rate_stats.subtitle')
    end

    def colors
      matches_colors
    end

    private

    def as_series(tacking_care_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.tacking_care_status'),
          data: tacking_care_status
        }
      ]
    end
  end
end
