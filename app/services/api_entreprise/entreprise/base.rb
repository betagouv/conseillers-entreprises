# frozen_string_literal: true

module ApiEntreprise::Entreprise
  class Base < ApiEntreprise::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiEntreprise::Request
    private

    def url_key
      @url_key ||= 'entreprises/'
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

    def non_diffusables
      @options[:non_diffusables] || true
    end
  end

  class Responder < ApiEntreprise::Responder
    def format_data
      data = @http_request.data
      # utilisation de strings pour fournir un json correctement formaté
      formatted_data = {
        'entreprise' => data["entreprise"],
        'etablissement_siege' => data["etablissement_siege"],
        'errors' => data["errors"]
      }
      raise ApiEntrepriseError, I18n.t('api_entreprise.invalid_siret_or_siren') if formatted_data.values.any?{|v| v.blank?}
      return formatted_data
    end
  end
end
