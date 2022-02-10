# frozen_string_literal: true

module ApiGeo
  module Query
    def self.city_with_code(citycode)
      citycode = ERB::Util.url_encode(citycode&.strip)
      url = "https://geo.api.gouv.fr/communes/#{citycode}?fields=nom,codesPostaux"

      http_response = HTTP.get(url)
      http_response.parse(:json)
    end
  end
end
