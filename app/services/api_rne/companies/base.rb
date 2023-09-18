# frozen_string_literal: true

module ApiRne::Companies
  class Base < ApiRne::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiRne::Request
    private

    def url_key
      @url_key ||= 'companies/'
    end

    def url
      @url ||= "#{base_url}#{url_key}#{@siren_or_siret}"
    end
  end

  class Responder < ApiRne::Responder
    def format_data
      pp @http_request.data
      registres = @http_request.data.dig('formality','content','registreAnterieur')
      {
        "forme_exercice" => @http_request.data.dig('formality', 'content', 'formeExerciceActivitePrincipale'),
        "rne_rcs" => registres.present? ? registres['rncs'] : nil,
        "rne_rnm" => registres.present? ? registres['rnm'] : nil,
      }
    end
  end
end
