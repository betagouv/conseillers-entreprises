module ApiFranceCompetence::Token
  class Base < ApiFranceCompetence::Base
    # rubocop:disable Style/RedundantInitialize
    def initialize; end
    # rubocop:enable Style/RedundantInitialize

    def call
      # token france_competence valable 7 jours par défaut
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
    def initialize
      p base_url
      p json_params
      p headers
      @http_response = HTTP.post(base_url, json: json_params, headers: headers)
      p @http_response
      byebug
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    private

    def json_params
      {
        login: login,
        password: password
      }.as_json
    end

    def headers
      @headers ||= {
        'X-Gravitee-Api-Key' => ENV.fetch('FRANCE_COMPETENCE_AUTH_KEY')
      }
    end

    def login
      @login ||= ENV.fetch('FRANCE_COMPETENCE_LOGIN')
    end

    def password
      @password ||= ENV.fetch('FRANCE_COMPETENCE_PASSWORD')
    end

    def base_url
      @base_url ||= 'https://api-preprod.francecompetences.fr/siropartfc-auth'
    end
  end

  class Responder < ApiFranceCompetence::Responder
    def format_data
      byebug
      @http_request.data['access_token']
    end
  end
end
