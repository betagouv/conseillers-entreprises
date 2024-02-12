module Stats::Matches
  # Taux de mises en relation restées sans réponse sur la totalité sur la totalité des besoins transmis au partenaire
  # (la lecture inverse correspond au taux de positionnement))
  class NotPositioning
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base

    def main_query
      matches_base_scope
    end

    def build_series
      query = filtered_main_query
      @not_positioning, @positioning = [], []
      search_range_by_month.each do |range|
        month_query = get_month_query(query, range)
        @positioning.push(month_query.not_status_quo.count)
        @not_positioning.push(month_query.status_quo.count)
      end

      as_series(@not_positioning, @positioning)
    end

    def subtitle
      I18n.t('stats.series.matches_not_positioning.subtitle')
    end

    private

    def as_series(not_positioning, positioning)
      [
        {
          name: I18n.t('stats.positioning'),
          data: positioning
        },
        {
          name: I18n.t('stats.not_positioning'),
          data: not_positioning
        }
      ]
    end
  end
end
