# frozen_string_literal: true

module ApiAdresse
  class Cities
    def find(postal_code)
      url = "https://api-adresse.data.gouv.fr/search/?q=#{postal_code}&type=municipality"

      begin
        http_response = HTTP.get(url)
        data = http_response.parse(:json)
        cities = []
        data['features'].each { |x| cities << x['properties']['label'] }
        cities
      rescue StandardError => e
        raise e
      end
    end
  end
end
