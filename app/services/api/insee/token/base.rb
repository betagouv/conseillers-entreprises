module Api::Insee::Token
  class Base < Api::Insee::Base
    # rubocop:disable Style/RedundantInitialize
    def initialize; end
    # rubocop:enable Style/RedundantInitialize

    def call
      # token insee valable 7 jours par défaut
      Rails.cache.fetch('insee_token', expires_in: 1.day) do
        http_request = Request.new
        if http_request.success?
          Responder.new(http_request).call
        else
          handle_error(http_request)
        end
      end
    end
  end

  class Request < Api::Insee::Request
    def initialize
      @http_response = HTTP.auth("Basic #{base_64_key}").post(base_url, form: { grant_type: 'client_credentials' })
      begin
        @data = @http_response.parse(:json)
      rescue StandardError => e
        @error = e
      end
    end

    private

    def consumer_key
      @consumer_key ||= ENV.fetch('INSEE_CONSUMER_KEY')
    end

    def consumer_token
      @consumer_token ||= ENV.fetch('INSEE_CONSUMER_TOKEN')
    end

    def base_64_key
      @base_64_key ||= Base64.strict_encode64("#{consumer_key}:#{consumer_token}")
    end

    def base_url
      @base_url ||= 'https://api.insee.fr/token'
    end
  end

  class Responder < Api::Insee::Responder
    def format_data
      @http_request.data['access_token']
    end
  end
end
