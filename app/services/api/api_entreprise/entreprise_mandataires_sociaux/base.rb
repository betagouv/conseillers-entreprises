# frozen_string_literal: true

module Api::ApiEntreprise::EntrepriseMandatairesSociaux
  class Base < Api::ApiEntreprise::Base
  end

  class Request < Api::ApiEntreprise::Request
    def api_result_key
      "mandataires_sociaux"
    end

    private

    def url_key
      @url_key ||= 'infogreffe/rcs/unites_legales/'
    end

    # infogreffe/rcs/unites_legales/{siren}/mandataires_sociaux
    def specific_url
      @specific_url ||= "#{url_key}#{@query}/mandataires_sociaux"
    end
  end

  class Responder < Api::ApiEntreprise::Responder
    def format_data
      { @http_request.api_result_key => @http_request.data['data'] }
    end
  end
end
