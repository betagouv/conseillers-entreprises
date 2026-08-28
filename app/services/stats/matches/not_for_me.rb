module Stats::Matches
  # Taux de mises en relation refusées sur la totalité des mises en relation transmises
  class NotForMe
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = not_for_me (target)
    def category_buckets
      [
        [:other, :else],
        [:not_for_me, "matches.status = '#{Match.statuses[:not_for_me]}'"]
      ]
    end

    def category_name(key)
      key == 'not_for_me' ? I18n.t('stats.not_for_me_status') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.matches_not_for_me.subtitle')
    end
  end
end
