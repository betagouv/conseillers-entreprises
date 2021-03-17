# frozen_string_literal: true

module ApiEntreprise
  class EtablissementRequest
    attr_reader :token, :siret, :connection, :options

    def initialize(token, siret, connection, options = {})
      @token = token
      @siret = siret
      @connection = connection
      @options = options
    end

    def response
      http_response = connection.get(url)
      EtablissementResponse.new(http_response)
    end

    def url
      # TODO: Send more relevant recipient and object values
      api_entreprises_params = {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises',
        non_diffusables: non_diffusables
      }.to_query

      "https://entreprise.api.gouv.fr/v2/etablissements/#{siret}?#{api_entreprises_params}"
    end

    private

    def non_diffusables
      options[:non_diffusables] || true
    end
  end
end
