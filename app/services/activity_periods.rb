module ActivityPeriods
  def self.period_name(period)
    if period.begin.month == period.end.month && period.begin == period.begin.beginning_of_month && period.end == period.end.end_of_month
      "#{period.begin.year}-#{period.begin.month}"
    elsif period.begin.quarter == period.end.quarter && period.begin == period.begin.beginning_of_quarter && period.end == period.end.end_of_quarter
      "#{period.begin.year}T#{period.begin.quarter}"
    else
      "#{I18n.l(period.begin)}-#{I18n.l(period.end)}"
    end
  end

  def self.past_periods(reference_date:, period_method:)
    today = Date.today
    past_two_years = [reference_date.year - 1, reference_date.year]
    intervals = []

    past_two_years.each do |year|
      date = Date.new(year, 1, 1)
      interval = date.send(period_method)
      while interval.end < today && interval.end <= date.end_of_year do
        intervals << interval
        interval = (interval.end + 1.day).send(period_method)
      end
    end

    intervals.reverse
  end

  def self.months = past_periods(reference_date: Date.today, period_method: :all_month)

  def self.quarters = past_periods(reference_date: 3.months.ago, period_method: :all_quarter)

  def self.years = past_periods(reference_date: 3.months.ago, period_method: :all_year)
end
