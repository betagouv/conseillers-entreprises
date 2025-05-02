class TimeDurationService::Quarters < TimeDurationService::Base
  def find_quarter_for_month(month)
    case month
    when 1,2,3
      "1"
    when 4,5,6
      "2"
    when 7,8,9
      "3"
    when 10,11,12
      "4"
    end
  end

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
