# frozen_string_literal: true

module ApiSirene
  class FullTextSearch
    def self.search(query)
      cleanquery = cleanquery(query)
      connection = HTTP
      http_response = connection.get(url(cleanquery))
      SireneResponse.new(cleanquery, http_response)
    end

    def self.cleanquery(query)
      query = I18n.transliterate(query, locale: :fr)
        .strip
        .squeeze(' ')
      ERB::Util.url_encode(query)
    end

    def self.url(query)
      "https://entreprise.data.gouv.fr/api/sirene/v1/full_text/#{query}"
    end
  end
end
