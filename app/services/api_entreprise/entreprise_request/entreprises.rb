# frozen_string_literal: true

module ApiEntreprise
  class EntrepriseRequest::Entreprises < EntrepriseRequest::Base

    private

    def url_key
      @url_key ||= 'entreprises'
    end

    def request_params
      {
        token: token,
        context: 'PlaceDesEntreprises',
        recipient: 'PlaceDesEntreprises',
        object: 'PlaceDesEntreprises',
        non_diffusables: non_diffusables
      }.to_query
    end

    def responder
      @responder ||= EntrepriseResponse::Entreprises
    end

    def non_diffusables
      options[:non_diffusables] || true
    end
  end
end
