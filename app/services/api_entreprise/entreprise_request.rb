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
      # TODO: Send more relevant recipient and object values
      "https://entreprise.api.gouv.fr/v2/entreprises/#{siren}?token=#{token}&context=PlaceDesEntreprises&recipient=PlaceDesEntreprises&object=PlaceDesEntreprises&non_diffusable=true"
    end
  end
end
