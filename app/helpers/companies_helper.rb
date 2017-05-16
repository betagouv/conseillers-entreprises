# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(DateTime.strptime(timestamp.to_s, '%s').to_date) if timestamp
  end
end
