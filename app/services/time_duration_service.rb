class TimeDurationService
  # Intervals trimestriels
  def self.past_year_quarters
    past_year_intervals(4)
  end

  # Intervals mensuels
  def self.past_year_months
    past_year_intervals(12)
  end

  # Découpe les dernières années en tranches de période
  def self.past_year_intervals(number_of_parts)
    today = Date.today
    years = past_two_years
    intervals = []

    years.each do |year|
      date ||= Date.new(year, 1, 1)
      number_of_parts.times do
        first_date = number_of_parts == 4 ? date.beginning_of_quarter : date.beginning_of_month
        last_date = number_of_parts == 4 ? date.end_of_quarter : date.end_of_month
        next if last_date >= today
        intervals << [first_date, last_date]
        date = last_date + 1.day
      end
    end
    intervals.reverse
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
    # Don't take into account the current year if we are before the end of the first quarter
    reference_date = 3.months.ago
    [reference_date.year - 1, reference_date.year]
  end
end
