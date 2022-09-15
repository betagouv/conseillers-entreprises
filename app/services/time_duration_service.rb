class TimeDurationService
  def self.past_year_quarters
    today = Date.today

    years = [today.year - 1, today.year]
    quarters = []
    years.each do |year|
      date ||= 1.year.ago
      4.times do
        next if date.end_of_quarter >= today
        quarters << [date.beginning_of_quarter, date.end_of_quarter]
        date = date.end_of_quarter + 1.day
      end
    end
    quarters.last(4).reverse
  end

  def self.find_quarter(month)
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
end
