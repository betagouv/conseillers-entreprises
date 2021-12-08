# frozen_string_literal: true

module ApiSirene
  class SirenSearch
    def self.search(query)
      connection = HTTP
      http_response = connection.get(url(query))
      SireneResponse.new(query, http_response)
    end

    def self.url(query)
      "https://entreprise.data.gouv.fr/api/sirene/v1/siren/#{query}"
    end
  end
end
