# frozen_string_literal: true

module ApiFranceCompetence::Siret
  class Base < ApiFranceCompetence::Base
    def request
      ApiFranceCompetence::Siret::Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiFranceCompetence::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=siret:#{@siren_or_siret}"
    end
  end

  class Responder < ApiFranceCompetence::Responder
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
