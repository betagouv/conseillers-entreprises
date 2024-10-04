module Api::Rne::Token
  class Base < Api::Rne::Base
    # rubocop:disable Style/RedundantInitialize
    def initialize(call_count = 0)
      @call_count = call_count
    end
    # rubocop:enable Style/RedundantInitialize

    def call
      invalid_cache_if_error
      Rails.cache.fetch('rne_token', expires_in: 58.minutes) do
        http_request = Request.new(@call_count)
        if http_request.success?
          Responder.new(http_request).call
        elsif first_try
          Api::Rne::Token::Base.new(@call_count + 1).call
        else
          handle_error(http_request)
        end
      end
    end

    def invalid_cache_if_error
      token = Rails.cache.fetch('rne_token')
      Rails.cache.delete('rne_token') if token.is_a?(Hash) && token&.dig("rne")&.key?("error")
    end

    def first_try
      @call_count == 0
    end
  end

  class Request < Api::Rne::Request
    def initialize(call_count)
      @call_count = call_count
      begin
        @http_response = HTTP.post(base_url, json: json_params)
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    private

    def json_params
      auth_array[@call_count].as_json
    end

    def auth_array
      [
        { username: ENV.fetch('RNE_USERNAME'), password: ENV.fetch('RNE_PASSWORD') },
        { username: ENV.fetch('RNE_USERNAME_2'), password: ENV.fetch('RNE_PASSWORD_2') }
      ]
    end

    def base_url
      @base_url ||= 'https://registre-national-entreprises.inpi.fr/api/sso/login'
    end
  end

  class Responder < Api::Rne::Responder
    def format_data
      @http_request.data['token']
    end
  end
end
