module TimeDurationService
  def self.period_name(period)
    if period.begin.month == period.end.month && period.begin == period.begin.beginning_of_month && period.end == period.end.end_of_month
      "#{period.begin.year}-#{period.begin.month}"
    elsif period.begin.quarter == period.end.quarter && period.begin == period.begin.beginning_of_quarter && period.end == period.end.end_of_quarter
      "#{period.begin.year}T#{period.begin.quarter}"
    else
      "#{I18n.l(period.begin)}-#{I18n.l(period.end)}"
    end
  end

  class Base
    def call
      today = Date.today
      past_two_years = [reference_date.year - 1, reference_date.year]
      intervals = []

      past_two_years.each do |year|
        date = Date.new(year, 1, 1)
        interval = interval_at(date)
        while interval.end < today && interval.end <= date.end_of_year do
          intervals << interval
          interval = interval(interval.end + 1.day)
        end
      end

      intervals.reverse
    end
  end

  class Months < Base
    def interval_at(date) = date.all_month

    def reference_date = Date.today
  end

  class Quarters < Base
    def interval_at(date) = date.all_quarter

    def reference_date = 3.months.ago # Don't take into account the current year if we are before the end of the first quarter
  end

  class Years < Base
    def interval_at(date) = date.all_year

    def reference_date = 3.months.ago # Don't take into account the current year if we are before the end of the first quarter
  end
end
