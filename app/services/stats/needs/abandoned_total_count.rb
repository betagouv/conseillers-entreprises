module Stats::Needs
  class AbandonedTotalCount
    include Stats::Needs::Base
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      needs_base_scope
    end

    # series[0] = other needs (compared), series[1] = abandoned (target).
    # EXISTS keeps counting at the need level despite the reminders_actions fan-out.
    def category_buckets
      abandoned = <<~SQL.squish
        EXISTS (SELECT 1 FROM reminders_actions ra
                WHERE ra.need_id = needs.id AND ra.category = #{RemindersAction.categories[:abandon]})
      SQL
      [
        [:other_needs, :else],
        [:abandoned_needs, abandoned]
      ]
    end

    def category_name(key)
      I18n.t("stats.series.needs_abandoned_total_count.#{key}")
    end

    # Secondary count is the total number of needs, not the abandoned sum.
    def secondary_count
      @secondary_count ||= filtered_main_query.size
    end

    def subtitle
      I18n.t('stats.series.needs_abandoned_total_count.subtitle')
    end
  end
end
