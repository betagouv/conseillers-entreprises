module Stats::Needs
  class ExchangeWithExpert
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      # This stat is available since 2020-09-01
      needs_base_scope
        .where(created_at: Time.zone.local(2020, 9, 1)..)
    end

    # series[0] = without_exchange (compared), series[1] = with_exchange (target)
    def category_buckets
      without = [
        Need.statuses[:not_for_me], Need.statuses[:done_not_reachable],
        Need.statuses[:quo], Need.statuses[:taking_care]
      ]
      with = [Need.statuses[:done], Need.statuses[:done_no_help]]
      [
        [:without_exchange, status_in(without)],
        [:with_exchange, status_in(with)]
      ]
    end

    def category_name(key)
      I18n.t("stats.series.needs_exchange_with_expert.#{key}")
    end

    def subtitle
      nil
    end

    private

    def status_in(statuses)
      "needs.status IN (#{statuses.map { |status| "'#{status}'" }.join(', ')})"
    end
  end
end
