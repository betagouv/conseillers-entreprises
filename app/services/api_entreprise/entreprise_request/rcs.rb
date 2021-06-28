# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequest::Rcs < EntrepriseRequest::Base

    private

    def url_key
      @url_key ||= 'extraits_rcs_infogreffe'
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
      @responder ||= EntrepriseResponse::Rcs
    end
  end
end
