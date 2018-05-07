# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    if timestamp
      I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date)
    end
  end

  def last_searches
    array = []
    searches = Search.of_user(current_user).recent
    searches.each do |search|
      if !array.map(&:query).include?(search.query)
        array << search
      end
    end
    array.first(5)
  end
end
