module Stats::Matches
  # Taux de mises en relation clôturées faute d’avoir pu joindre l’entreprise sur la totalité des mises en relation transmises
  class DoneNotReachable
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = done_not_reachable (target)
    def category_buckets
      [
        [:other, :else],
        [:done_not_reachable, "matches.status = '#{Match.statuses[:done_not_reachable]}'"]
      ]
    end

    def category_name(key)
      key == 'done_not_reachable' ? I18n.t('stats.not_reachable_status') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.matches_done_not_reachable.subtitle')
    end
  end
end
