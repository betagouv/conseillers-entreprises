# frozen_string_literal: true

module ApiAdresse
  module Query
    def self.cities_of_postcode(postcode)
      postcode = ERB::Util.url_encode(postcode)
      url = "https://api-adresse.data.gouv.fr/search/?q=#{postcode}&type=municipality"

      http_response = HTTP.get(url)
      data = http_response.parse(:json)
      data.dig('features')&.map{ |hash| hash.dig('properties', 'city') }
    end

    def self.insee_code_for_city(city, postcode)
      city = ERB::Util.url_encode(city)
      postcode = ERB::Util.url_encode(postcode)
      url = "https://api-adresse.data.gouv.fr/search/?q=#{city}&postcode=#{postcode}&type=municipality"

      http_response = HTTP.get(url)
      data = http_response.parse(:json)
      data.dig('features', 0, 'properties', 'citycode')
    end
  end
end
