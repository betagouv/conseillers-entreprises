module Stats::Matches
  class Positioning
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    def category_buckets
      [
        [:not_positioning, "matches.status = '#{Match.statuses[:quo]}'"],
        [:positioning, :else]
      ]
    end

    def category_name(key)
      key == 'positioning' ? I18n.t('stats.positioning') : I18n.t('stats.not_positioning')
    end

    def subtitle
      I18n.t('stats.series.matches_positioning.subtitle')
    end
  end
end
