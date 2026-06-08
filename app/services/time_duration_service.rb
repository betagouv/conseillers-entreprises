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
end
