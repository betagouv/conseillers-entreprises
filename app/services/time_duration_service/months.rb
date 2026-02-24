class TimeDurationService::Months < TimeDurationService::Base
  private

  def first_interval_date(date)
    date.beginning_of_month
  end

  def last_interval_date(date)
    date.end_of_month
  end

  def number_of_parts
    12
  end

  def past_two_years
    today = Date.today
    [today.year - 1, today.year]
  end
end
