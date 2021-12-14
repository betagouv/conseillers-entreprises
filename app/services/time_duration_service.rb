class TimeDurationService
  def self.past_year_quarters
    today = Date.today

    years = [today.year - 1, today.year]
    quarters = []
    years.each do |year|
      date ||= Date.parse("1.1.#{year}")
      4.times do
        next if date.end_of_quarter > today
        quarters << [date.beginning_of_quarter, date.end_of_quarter]
        date = date.end_of_quarter + 1.day
      end
    end
    quarters.last(4).reverse
  end

  def self.find_quarter(month)
    case month
    when 1,2,3
      I18n.t('time_duration_service.find_quarter.first')
    when 4,5,6
      I18n.t('time_duration_service.find_quarter.second')
    when 7,8,9
      I18n.t('time_duration_service.find_quarter.third')
    when 10,11,12
      I18n.t('time_duration_service.find_quarter.fourth')
    end
  end
end
