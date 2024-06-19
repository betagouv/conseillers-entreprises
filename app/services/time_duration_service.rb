class TimeDurationService
  def self.past_year_quarters
    today = Date.today

    years = past_two_years
    quarters = []
    years.each do |year|
      date ||= Date.new(year, 1, 1)
      4.times do
        next if date.end_of_quarter >= today
        quarters << [date.beginning_of_quarter, date.end_of_quarter]
        date = date.end_of_quarter + 1.day
      end
    end
    quarters.reverse
  end

  def self.find_quarter_for_month(month)
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

  def self.past_two_years
    today = Date.today
    # Don't take into account the current year if we are before the end of the first quarter
    if today.month <= 3
      [today.year - 2, today.year - 1]
    else
      [today.year - 1, today.year]
    end
  end
end
