module Stats::Needs
  class Done
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    # series[0] = other statuses (compared), series[1] = done (target)
    def category_buckets
      [
        [:other, :else],
        [:done, "needs.status = '#{Need.statuses[:done]}'"]
      ]
    end

    def category_name(key)
      key == 'done' ? I18n.t('stats.status_done') : I18n.t('stats.other_status')
    end

    def subtitle
      I18n.t('stats.series.needs_done.subtitle')
    end
  end
end
