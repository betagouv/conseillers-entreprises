class TimeDurationService::Quarters < TimeDurationService::Base
  private

  def first_interval_date(date)
    date.beginning_of_quarter
  end

  def last_interval_date(date)
    date.end_of_quarter
  end

  def number_of_parts
    4
  end
end
