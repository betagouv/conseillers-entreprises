class TimeDurationService::Years < TimeDurationService::Base
  private

  def first_interval_date(date)
    date.beginning_of_year
  end

  def last_interval_date(date)
    date.end_of_year
  end

  def number_of_parts
    1
  end
end
