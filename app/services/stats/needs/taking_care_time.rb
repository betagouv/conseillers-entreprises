module Stats::Needs::TakingCareTime
  include ::Stats::BaseStats

  def main_query
    Need.with_exchange
      .joins(:matches)
      .where(created_at: @start_date..@end_date)
  end

  def number_of_days
    @number_of_days ||= 5
  end

  def build_series
    query = main_query
    query = Stats::Filters::Needs.new(query, self).call

    @taken_care_before = []
    @taken_care_after = []

    search_range_by_month.each do |range|
      month_query = query.created_between(range.first, range.last)
      @taken_care_before.push(month_query.taken_care_before(number_of_days).count)
      @taken_care_after.push(month_query.taken_care_after(number_of_days).count)
    end

    as_series(@taken_care_before, @taken_care_after)
  end

  def count
    series
    @count ||= percentage_two_numbers(@taken_care_before, @taken_care_after)
  end

  private

  def as_series(taken_care_before, taken_care_after)
    [
      {
        name: taken_care_after_label,
          data: taken_care_after
      },
      {
        name: taken_care_before_label,
          data: taken_care_before
      }
    ]
  end
end
