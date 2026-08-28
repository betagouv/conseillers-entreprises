module Stats::Needs
  class Quo
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def category_buckets
      [
        [:other, :else],
        [:quo, "needs.status = '#{Need.statuses[:quo]}'"]
      ]
    end

    def category_name(key)
      key == 'quo' ? I18n.t('stats.status_quo') : I18n.t('stats.other_status')
    end
  end
end
