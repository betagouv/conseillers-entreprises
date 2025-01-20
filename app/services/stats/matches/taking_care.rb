module Stats::Matches
  # Taux de mises en relation en cours de prises en charge sur l’ensemble des mises en relation transmises
  class TakingCare
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end

    def build_series
      query = filtered_main_query
      @taking_care_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @taking_care_status.push(month_query.status_taking_care.count)
        @other_status.push(month_query.not_status_taking_care.count)
      end

      as_series(@taking_care_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_taking_care.subtitle')
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
