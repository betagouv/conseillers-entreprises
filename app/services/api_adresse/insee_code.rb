# frozen_string_literal: true

module ApiAdresse
  class InseeCode
    def fetch_from_api(city, postal_code)
      city = ERB::Util.url_encode(city)
      url = "https://api-adresse.data.gouv.fr/search/?q=#{city}&postcode=#{postal_code}&type=municipality"

      begin
        http_response = HTTP.get(url)
        data = http_response.parse(:json)
        data.dig('features', 0, 'properties', 'citycode')
      rescue StandardError => e
        raise e
      end
    end
  end
end
