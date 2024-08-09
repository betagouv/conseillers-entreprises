module ApiRne::Token
  class Base < ApiRne::Base
    USERNAME_1 = ENV.fetch('RNE_USERNAME')
    PASSWORD_1 = ENV.fetch('RNE_PASSWORD')
    USERNAME_2 = ENV.fetch('RNE_USERNAME_2')
    PASSWORD_2 = ENV.fetch('RNE_PASSWORD_2')

    # rubocop:disable Style/RedundantInitialize
    def initialize(username = USERNAME_1, password = PASSWORD_1)
      @username = username
      @password = password
    end
    # rubocop:enable Style/RedundantInitialize

    def call
      invalid_cache_if_error
      Rails.cache.fetch('rne_token', expires_in: 58.minutes) do
        http_request = Request.new(@username, @password)
        if http_request.success?
          Responder.new(http_request).call
        elsif first_try
          ApiRne::Token::Base.new(USERNAME_2, PASSWORD_2).call
        else
          handle_error(http_request)
        end
      end
    end

    def invalid_cache_if_error
      Rails.cache.delete('rne_token') if Rails.cache.fetch('rne_token')&.dig("rne")&.key?("error")
    end

    def first_try
      @username == USERNAME_1
    end
  end

  class Request < ApiRne::Request
    def initialize(username, password)
      @username = username
      @password = password
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
        username: @username,
        password: @password
      }.as_json
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
