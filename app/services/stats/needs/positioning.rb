module Stats::Needs
  class Positioning
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def category_buckets
      [
        [:not_positioning, "needs.status = '#{Need.statuses[:quo]}'"],
        [:positioning, :else]
      ]
    end

    def category_name(key)
      key == 'positioning' ? I18n.t('stats.positioning') : I18n.t('stats.not_positioning')
    end

    def subtitle
      I18n.t('stats.series.needs_positioning.subtitle')
    end
  end
end
