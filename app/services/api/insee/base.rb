module Api::Insee
  class Base < Api::Base
    def call
      Rails.cache.fetch([id_key, @query].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        else
          notify_tech_error(http_request)
          raise Api::UnavailableApiError, Request::DEFAULT_TECHNICAL_ERROR_MESSAGE
        end
      end
    end
  end

  class Request < Api::Request
    def get_url
      HTTP.get(url, headers: headers)
    end

    def headers
      @headers ||= {
        'X-INSEE-Api-Key-Integration' => ENV.fetch('SIRENE_API_KEY')
      }
    end

    def not_found?
      response_status.not_found?
    end

    def data_error_message
      @data['errors']&.join('\n')
    end

    private

    def base_url
      @base_url ||= "https://api.insee.fr/api-sirene/3.11/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@query}"
    end
  end

  class Responder < Api::Responder
    def check_if_foreign_facility(etablissement)
      foreign_country = etablissement['adresseEtablissement']["libellePaysEtrangerEtablissement"]
      raise Api::ApiError, I18n.t('api_requests.foreign_facility', country: foreign_country.capitalize) if foreign_country.present?
    end
  end
end
