module Stats::Needs
  class DoneNotReachable
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = done_not_reachable (target)
    def category_buckets
      [
        [:other, :else],
        [:done_not_reachable, "needs.status = '#{Need.statuses[:done_not_reachable]}'"]
      ]
    end

    def category_name(key)
      key == 'done_not_reachable' ? I18n.t('stats.status_done_not_reachable') : I18n.t('stats.other_status')
    end
  end
end
