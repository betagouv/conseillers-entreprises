module Stats::Matches
  # Taux de mises en relation refusées sur la totalité des mises en relation transmises
  class NotForMe
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end

    def build_series
      query = filtered_main_query
      @not_for_me_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @not_for_me_status.push(month_query.status_not_for_me.count)
        @other_status.push(month_query.not_status_not_for_me.count)
      end

      as_series(@not_for_me_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_not_for_me.subtitle')
    end

    private

    def as_series(not_for_me_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.not_for_me_status'),
          data: not_for_me_status
        }
      ]
    end
  end
end
