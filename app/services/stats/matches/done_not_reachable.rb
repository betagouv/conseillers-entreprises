module Stats::Matches
  # Taux de mises en relation clôturées faute d’avoir pu joindre l’entreprise sur la totalité des mises en relation transmises
  class DoneNotReachable
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end

    def build_series
      query = filtered_main_query
      @not_reachable_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @not_reachable_status.push(month_query.status_done_not_reachable.count)
        @other_status.push(month_query.not_status_done_not_reachable.count)
      end

      as_series(@not_reachable_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_done_not_reachable.subtitle')
    end

    private

    def as_series(not_reachable_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.not_reachable_status'),
          data: not_reachable_status
        }
      ]
    end
  end
end
