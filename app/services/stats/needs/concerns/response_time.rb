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

  # A need is "before" if it has an exchange match handled within number_of_days.
  def category_buckets
    gap = "ABS(DATE_PART('day', matches.taken_care_of_at - matches.sent_at))"
    [
      [:after, "NOT EXISTS (#{quick_match_exists_sql('gm')})"],
      [:before, "matches.status IN (#{quick_statuses}) AND #{gap} < #{number_of_days}"]
    ]
  end

  def category_name(key)
    key == 'before' ? taken_care_before_label : taken_care_after_label
  end

  def count
    @count ||= percentage_two_numbers(series[1][:data], series[0][:data])
  end

  private

  def quick_statuses
    [Match.statuses[:done], Match.statuses[:done_no_help]].map { |status| "'#{status}'" }.join(', ')
  end

  def quick_match_exists_sql(alias_name)
    <<~SQL.squish
      SELECT 1 FROM matches #{alias_name}
      WHERE #{alias_name}.need_id = needs.id AND #{alias_name}.status IN (#{quick_statuses})
        AND ABS(DATE_PART('day', #{alias_name}.taken_care_of_at - #{alias_name}.sent_at)) < #{number_of_days}
    SQL
  end
end
