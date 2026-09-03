module Stats::Matches
  # Taux de mises en relation sans aide disponible sur la totalité des mises en relations transmises
  class DoneNoHelp
    include ::Stats::BaseStats
    include ::Stats::TwoRatesStats
    include Stats::Matches::Base
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = done_no_help (target)
    def category_buckets
      [
        [:other, :else],
        [:done_no_help, "matches.status = '#{Match.statuses[:done_no_help]}'"]
      ]
    end

    def category_name(key)
      key == 'done_no_help' ? I18n.t('stats.done_no_help_status') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.matches_done_no_help.subtitle')
    end
  end
end
