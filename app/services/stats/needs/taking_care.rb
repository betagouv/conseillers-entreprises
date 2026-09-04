module Stats::Needs
  class TakingCare
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = taking_care (target)
    def category_buckets
      [
        [:other, :else],
        [:taking_care, "needs.status = '#{Need.statuses[:taking_care]}'"]
      ]
    end

    def category_name(key)
      key == 'taking_care' ? I18n.t('stats.status_taking_care') : I18n.t('stats.other_status')
    end
  end
end
