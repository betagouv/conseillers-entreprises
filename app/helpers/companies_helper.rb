# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date) rescue nil
  end
end
