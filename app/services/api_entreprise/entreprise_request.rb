# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequest
    attr_reader :token, :siren, :connection

    def initialize(token, siren, connection)
      @token = token
      @siren = siren
      @connection = connection
    end

    def response
      http_response = connection.get(url)
      EntrepriseResponse.new(http_response)
    end

    def url
      "https://api.apientreprise.fr/v2/entreprises/#{siren}?token=#{token}"
    end
  end
end
