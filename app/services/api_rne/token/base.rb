module ApiRne::Token
  class Base < ApiRne::Base
    # rubocop:disable Style/RedundantInitialize
    def initialize; end
    # rubocop:enable Style/RedundantInitialize

    def call
      Rails.cache.fetch('rne_token', expires_in: 1.hour) do
        http_request = Request.new
        if http_request.success?
          Responder.new(http_request).call
        else
          handle_error(http_request)
        end
      end
    end
  end

  class Request < ApiRne::Request
    def initialize
      @http_response = HTTP.post(base_url, json: json_params)
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    private

    def json_params
      {
        username: username,
        password: password
      }.as_json
    end

    def username
      @username ||= ENV.fetch('RNE_USERNAME')
    end

    def password
      @password ||= ENV.fetch('RNE_PASSWORD')
    end

    def base_url
      @base_url ||= 'https://registre-national-entreprises.inpi.fr/api/sso/login'
    end
  end

  class Responder < ApiRne::Responder
    def format_data
      @http_request.data['token']
    end
  end
end
