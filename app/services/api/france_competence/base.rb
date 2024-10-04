module Api::FranceCompetence
  class Base < Api::Base
    def handle_error(http_request)
      if http_request.has_tech_error?
        notify_tech_error(http_request)
        return { "opco_fc" => { "error" => Request::DEFAULT_TECHNICAL_ERROR_MESSAGE } }
      end
      return { "opco_fc" => { "error" => http_request.error_message } }
    end
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
