module Api::Insee
  class Base < Api::Base
    def call
      Rails.cache.fetch([id_key, @query].join('-'), expires_in: 12.hours) do
        http_request = request
        if http_request.success?
          responder(http_request).call
        elsif http_request.not_found?
          raise Api::BasicError, I18n.t('api_requests.non_diffusible_error')
        else
          handle_error(http_request)
        end
      end
    end
  end

  class Request < Api::Request
    def get_url
      HTTP.auth("Bearer #{token}").get(url)
    end

    def token
      @token ||= Api::Insee::Token::Base.new.call
    end

    def not_found?
      response_status.not_found?
    end

    def data_error_message
      @data['errors']&.join('\n')
    end

    private

    def base_url
      @base_url ||= "https://api.insee.fr/entreprises/sirene/V3.11/"
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
      # raise_technical_error(message: I18n.t('api_requests.foreign_facility', country: foreign_country.capitalize)) if foreign_country.present?

      raise Api::BasicError, I18n.t('api_requests.foreign_facility', country: foreign_country.capitalize) if foreign_country.present?
    end
  end
end
