module Stats::Matches
  # Taux de mises en relation restées sans réponse sur la totalité sur la totalité des besoins transmis au partenaire
  # (la lecture inverse correspond au taux de positionnement))
  class NotPositioningRate
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
      @not_positioning, @positioning = [], []
      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @positioning.push(month_query.not_status_quo.count)
        @not_positioning.push(month_query.status_quo.count)
      end

      as_series(@not_positioning, @positioning)
    end

    def count
      build_series
      percentage_two_numbers(@not_positioning, @positioning)
    end

    def subtitle
      I18n.t('stats.series.not_positioning_rate.subtitle')
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
