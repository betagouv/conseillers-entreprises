# frozen_string_literal: true

module ApiEntreprise
  class RcsRequest
    attr_reader :token, :siren, :connection, :options

    def initialize(token, siren, connection, options = {})
      @token = token
      @siren = siren
      @connection = connection
      @options = options
    end

    def response
      http_response = connection.get(url)
      EntrepriseResponse.new(http_response)
    end

    def url
      # TODO: Send more relevant recipient and object values
      api_entreprises_params = {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises',
      }.to_query
      "https://entreprise.api.gouv.fr/v2/extraits_rcs_infogreffe/#{siren}?#{api_entreprises_params}"
    end

    private

    def non_diffusables
      options[:non_diffusables] || true
    end
  end
end
