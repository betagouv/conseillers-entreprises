module Stats::Matches
  # Taux de mises en relation restées sans réponse sur la totalité sur la totalité des besoins transmis au partenaire
  # (la lecture inverse correspond au taux de positionnement))
  class NotPositioning
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = positioning (non-quo), series[1] = not_positioning (status quo, target)
    def category_buckets
      [
        [:positioning, :else],
        [:not_positioning, "matches.status = '#{Match.statuses[:quo]}'"]
      ]
    end

    def category_name(key)
      key == 'positioning' ? I18n.t('stats.positioning') : I18n.t('stats.not_positioning')
    end

    def subtitle
      I18n.t('stats.series.matches_not_positioning.subtitle')
    end
  end
end
