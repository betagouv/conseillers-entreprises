# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequest::Rm < EntrepriseRequest::Base
    private

    def url_key
      @url_key ||= 'entreprises_artisanales_cma'
    end

    def request_params
      {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises',
      }.to_query
    end

    def responder
      @responder ||= EntrepriseResponse::Rm
    end
  end
end
