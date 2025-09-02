module Api::ApiEntreprise
  class Base < Api::Base
  end

  class Request < Api::Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.default_error_message.etablissement')

    def get_url
      HTTP.auth("Bearer #{token}").get(url)
    end

    def data_error_message
      [@data['errors']&.first&.dig("title"), @data['errors']&.first&.dig("detail")].join(' : ')
    end

    private

    def token
      @token ||= ENV.fetch('API_ENTREPRISE_TOKEN')
    end

    def version
      @version ||= 'v3'
    end

    def base_url
      @base_url ||= "https://entreprise.api.gouv.fr/#{version}/"
    end

    def url_key
      @url_key ||= ""
    end

    def specific_url
      [url_key, @query].join
    end

    def url
      @url ||= "#{base_url}#{specific_url}?#{request_params}"
    end

    def request_params
      {
        context: 'PlaceDesEntreprises',
        recipient: '13002526500013',
        object: 'PlaceDesEntreprises'
      }.to_query
    end
  end

  class Responder < Api::Responder; end
end
