module Stats::Needs::Concerns::ResponseTime
  include ::Stats::BaseStats
  include Stats::Concerns::PartitionedCategory

  def base_scope
    Need.joins(:matches).where(created_at: @start_date..@end_date)
  end

  def filtered(query)
    Stats::Filters::Needs.new(query, self).call
  end

  # Count at the need level despite the matches join fan-out.
  def category_count_distinct?
    true
  end

  # series[0] = after (compared), series[1] = before (target). A need is "before"
  # when it has at least one exchange match handled within number_of_days; the
  # EXISTS keeps this a need-level test (no double counting), and NULL gaps fall
  # out of both buckets like the original where/where.not.
  def category_buckets
    exists = <<~SQL.squish
      EXISTS (SELECT 1 FROM matches m
              WHERE m.need_id = needs.id
                AND m.status IN (#{exchange_match_statuses})
                AND ABS(DATE_PART('day', m.taken_care_of_at - m.sent_at)) < #{number_of_days})
    SQL
    [
      [:after, :else],
      [:before, exists]
    ]
  end

  def category_name(key)
    key == 'before' ? taken_care_before_label : taken_care_after_label
  end

  def count
    @count ||= percentage_two_numbers(series[1][:data], series[0][:data])
  end

  private

  def exchange_match_statuses
    [Match.statuses[:done], Match.statuses[:done_no_help]].map { |status| "'#{status}'" }.join(', ')
  end
end
