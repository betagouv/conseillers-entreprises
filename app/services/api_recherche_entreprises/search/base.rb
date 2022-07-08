# frozen_string_literal: true

module ApiRechercheEntreprises::Search
  class Base < ApiRechercheEntreprises::Base
    def request
      Request.new(@query, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiRechercheEntreprises::Request
    private

    def url_key
      @url_key ||= 'search'
    end

    def url
      @url ||= "#{base_url}#{url_key}?q=#{@query}"
    end
  end

  class Responder < ApiRechercheEntreprises::Responder
    def format_data
      res = @http_request.data["results"].map do |entreprise|
        siege = entreprise['siege']
        next if (siege["code_pays_etranger"].present? || entreprise['nombre_etablissements_ouverts'] < 1)
        {
          entreprise: entreprise.except('siege'),
          etablissement_siege: entreprise['siege']
        }
      end
      res.compact
    end
  end
end
