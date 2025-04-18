class TimeDurationService::Base
  def call
    today = Date.today
    years = past_two_years
    intervals = []

    years.each do |year|
      date ||= Date.new(year, 1, 1)
      number_of_parts.times do
        first_date = first_interval_date(date)
        last_date = last_interval_date(date)
        next if last_date >= today
        intervals << [first_date, last_date]
        date = last_date + 1.day
      end
    end

    intervals.reverse
  end

  private

  def past_two_years
    # Don't take into account the current year if we are before the end of the first quarter
    reference_date = 3.months.ago
    [reference_date.year - 1, reference_date.year]
  end
end
