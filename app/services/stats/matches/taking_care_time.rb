module Stats::Matches::TakingCareTime
  include ::Stats::BaseStats
  include ::Stats::TwoRatesStats
  include Stats::Matches::Base
  include Stats::Concerns::PartitionedCategory

  def main_query
    matches_base_scope.with_exchange
  end

  def number_of_days
    @number_of_days ||= 5
  end

  # This graph buckets by the match's own creation month.
  def month_group_table(_query)
    'matches'
  end

  # series[0] = after (compared), series[1] = before (target). Explicit conditions
  # (no :else) so matches with a NULL taken_care_of_at fall out of both buckets.
  def category_buckets
    gap = "ABS(DATE_PART('day', matches.taken_care_of_at - matches.sent_at))"
    [
      [:after, "NOT (#{gap} < #{number_of_days})"],
      [:before, "#{gap} < #{number_of_days}"]
    ]
  end

  def category_name(key)
    key == 'before' ? taken_care_before_label : taken_care_after_label
  end
end
