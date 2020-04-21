# frozen_string_literal: true

module ApiAdresse
  module Query
    def self.cities_of_postcode(postcode)
      postcode = ERB::Util.url_encode(postcode&.strip)
      url = "https://api-adresse.data.gouv.fr/search/?q=#{postcode}&type=municipality"

      http_response = HTTP.get(url)
      http_response.parse(:json)
    end

    def self.city_with_code(citycode)
      citycode = ERB::Util.url_encode(citycode&.strip)
      url = "https://geo.api.gouv.fr/communes/#{citycode}?fields=nom,codesPostaux"

      http_response = HTTP.get(url)
      http_response.parse(:json)
    end
  end
end
