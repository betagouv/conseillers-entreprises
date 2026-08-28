module Stats::Matches
  # Taux de mises en relation en cours de prises en charge sur l’ensemble des mises en relation transmises
  class TakingCare
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = taking_care (target)
    def category_buckets
      [
        [:other, :else],
        [:taking_care, "matches.status = '#{Match.statuses[:taking_care]}'"]
      ]
    end

    def category_name(key)
      key == 'taking_care' ? I18n.t('stats.taking_care_status') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.matches_taking_care.subtitle')
    end
  end
end
