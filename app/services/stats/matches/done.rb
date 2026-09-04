module Stats::Matches
  # Taux de mises en relation clôturées grâce à une aide proposée sur la totalité des mises en relation transmises
  class Done
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = done (target)
    def category_buckets
      [
        [:other, :else],
        [:done, "matches.status = '#{Match.statuses[:done]}'"]
      ]
    end

    def category_name(key)
      key == 'done' ? I18n.t('stats.done_status') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.matches_done.subtitle')
    end
  end
end
