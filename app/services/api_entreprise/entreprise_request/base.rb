# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequest::Base
    attr_reader :token, :siren, :connection, :options

    BASE_URL = "https://entreprise.api.gouv.fr/v2/"

    def initialize(token, siren, connection, options = {})
      @token = token
      @siren = siren
      @connection = connection
      @options = options
    end

    def response
      http_response = connection.get(url)
      responder.new(http_response)
    end

    private

    def url_key
      @url_key ||= ""
    end

    def url
      "#{BASE_URL}#{url_key}/#{siren}?#{request_params}"
    end

    def request_params
      {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises'
      }.to_query
    end

    def responder
      @responder ||= EntrepriseResponse::Base
    end
  end
end
