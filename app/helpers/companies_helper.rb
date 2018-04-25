# frozen_string_literal: true

module CompaniesHelper
  def date_from_timestamp(timestamp)
    I18n.l(Time.strptime(timestamp.to_s, '%s').in_time_zone.to_date) if timestamp
  end

  def last_searches
    array = []
    searches = Search.of_user(current_user).recent
    searches.each do |search|
      array << search if !array.map(&:query).include?(search.query)
    end
    array.first(5)
  end
end
