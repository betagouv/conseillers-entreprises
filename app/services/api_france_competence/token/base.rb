module ApiFranceCompetence::Token
  class Base < ApiFranceCompetence::Base
    # rubocop:disable Style/RedundantInitialize
    def initialize; end
    # rubocop:enable Style/RedundantInitialize

    def call
      Rails.cache.fetch('france_competence_token', expires_in: 1.day) do
        http_request = Request.new
        if http_request.success?
          Responder.new(http_request).call
        else
          handle_error(http_request)
        end
      end
    end
  end

  class Request < ApiFranceCompetence::Request
    ERROR_CODES = {
      '401' => "API key invalid or expired",
      '404' => "Login or password invalid"
    }.freeze

    def initialize
      @http_response = HTTP.post(url, json: json_params, headers: headers)
      begin
        @data = @http_response.body.to_s
      rescue StandardError => e
        @error = e
      end
    end

    def error_message
      @error&.message || ERROR_CODES[data['code']] || @http_response.status.reason || DEFAULT_ERROR_MESSAGE
    end

    private

    def headers
      @headers ||= {
        'X-Gravitee-Api-Key' => ENV.fetch('FRANCE_COMPETENCE_AUTH_KEY')
      }
    end

    def json_params
      {
        'login' => login,
        'password' => password
      }.as_json
    end

    def login
      @login ||= ENV.fetch('FRANCE_COMPETENCE_LOGIN')
    end

    def password
      @password ||= ENV.fetch('FRANCE_COMPETENCE_PASSWORD')
    end

    def url
      @url ||= "#{base_url}siropartfc-auth/login"
    end
  end

  class Responder < ApiFranceCompetence::Responder; end
end
