# frozen_string_literal: true

module ApiInsee::Siren
  class Base < ApiInsee::Base
    def request
      Request.new(@siren_or_siret, @options)
    end

    def responder(http_request)
      Responder.new(http_request)
    end
  end

  class Request < ApiInsee::Request
    private

    def url_key
      @url_key ||= 'siren/'
    end
  end

  class Responder < ApiInsee::Responder
    def format_data
      @http_request.data["uniteLegale"]
    end
  end
end
