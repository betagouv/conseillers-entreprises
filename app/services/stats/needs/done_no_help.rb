module Stats::Needs
  class DoneNoHelp
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def category_buckets
      [
        [:other, :else],
        [:done_no_help, "needs.status = '#{Need.statuses[:done_no_help]}'"]
      ]
    end

    def category_name(key)
      key == 'done_no_help' ? I18n.t('stats.status_done_no_help') : I18n.t('stats.other_status')
    end
  end
end
