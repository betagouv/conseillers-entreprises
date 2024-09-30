# frozen_string_literal: true

module Api::Insee::Siret
  class Base < Api::Insee::Base
  end

  class Request < Api::Insee::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=siret:#{@siren_or_siret}"
    end
  end

  class Responder < Api::Insee::Responder
    def format_data
      data = @http_request.data
      etablissements = data["etablissements"]
      check_if_foreign_facility(etablissements.first)
      entreprise = format_entreprise(data["etablissements"][0])
      {
        entreprise: entreprise,
        etablissements: etablissements,
        nombre_etablissements_ouverts: 1,
      }
    end

    def format_entreprise(first_etablissement)
      { siren: first_etablissement['siren'] }.merge(first_etablissement['uniteLegale'])
    end
  end
end
