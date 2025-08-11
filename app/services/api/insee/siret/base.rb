module Api::Insee::Siret
  class Base < Api::Insee::Base
  end

  class Request < Api::Insee::Request
    private

    def url_key
      @url_key ||= 'siret/'
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@query}"
    end
  end

  class Responder < Api::Insee::Responder
    def format_data
      data = @http_request.data
      etablissement = data["etablissement"]
      check_if_foreign_facility(etablissement)
      entreprise = format_entreprise(etablissement)
      {
        entreprise: entreprise,
        etablissements: [etablissement],
        nombre_etablissements_ouverts: 1,
      }
    end

    def format_entreprise(etablissement)
      { siren: etablissement['siren'] }.merge(etablissement['uniteLegale'])
    end
  end
end
