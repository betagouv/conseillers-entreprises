module Api::FranceCompetence
  class Base < Api::Base
  end

  class Request < Api::Request
    ERROR_CODES = {}

    def get_url
      @http_response = HTTP.auth("Bearer #{token}").get(url, headers: headers)
    end

    def token
      @token ||= Api::FranceCompetence::Token::Base.new.call
    end

    def headers
      @headers ||= {
        'X-Gravitee-Api-Key' => ENV.fetch('FRANCE_COMPETENCE_SIRO_KEY')
      }
    end

    def success?
      @error.nil? && response_status.success? && !ERROR_CODES.key?(data['code'])
    end

    def data_error_message
      @data['errors']&.join('\n')
    end

    def api_result_key
      "opco_fc"
    end

    private

    def base_url
      @base_url ||= "https://api.francecompetences.fr/"
    end

    def url_key
      @url_key ||= ""
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@query}"
    end
  end

  class Responder < Api::Responder; end
end
