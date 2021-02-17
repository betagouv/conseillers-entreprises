# frozen_string_literal: true

module ApiEntreprise
  class EtablissementRequest
    attr_reader :token, :siret, :connection

    def initialize(token, siret, connection)
      @token = token
      @siret = siret
      @connection = connection
    end

    def response
      http_response = connection.get(url)
      EtablissementResponse.new(http_response)
    end

    def url
      # TODO: Send more relevant recipient and object values
      "https://entreprise.api.gouv.fr/v2/etablissements/#{siret}?token=#{token}&context=PlaceDesEntreprises&recipient=PlaceDesEntreprises&object=PlaceDesEntreprises&non_diffusable=true"
    end
  end
end
