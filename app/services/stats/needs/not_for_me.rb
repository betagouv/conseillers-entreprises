module Stats::Needs
  class NotForMe
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = not_for_me (target)
    def category_buckets
      [
        [:other, :else],
        [:not_for_me, "needs.status = '#{Need.statuses[:not_for_me]}'"]
      ]
    end

    def category_name(key)
      key == 'not_for_me' ? I18n.t('stats.status_not_for_me') : I18n.t('stats.other_status')
    end
  end
end
