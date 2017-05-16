# frozen_string_literal: true

module QwantApiService
  def self.results_for_query(query)
    raise ParameterMissingError, 'Query is missing' if query.blank?
    qwant_api_url = "https://api.qwant.com/egp/search/web?q=#{query}"
    JSON.parse open(qwant_api_url).read
  end

  class ParameterMissingError < StandardError; end
end
