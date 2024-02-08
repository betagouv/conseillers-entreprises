module Stats::Matches
  # Taux de mises en relation clôturées grâce à une aide proposée sur la totalité des mises en relation transmises
  class Done
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end


    def build_series
      query = filtered_main_query
      @done_status = []
      @other_status = []

      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @done_status.push(month_query.status_done.count)
        @other_status.push(month_query.not_status_done.count)
      end

      as_series(@done_status, @other_status)
    end

    def subtitle
      I18n.t('stats.series.matches_done.subtitle')
    end

    private

    def as_series(done_status, other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: other_status
        },
        {
          name: I18n.t('stats.done_status'),
          data: done_status
        }
      ]
    end
  end
end
