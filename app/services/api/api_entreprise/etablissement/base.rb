# frozen_string_literal: true

module Api::ApiEntreprise::Etablissement
  class Base < Api::ApiEntreprise::Base
    def handle_error(http_request)
      handle_error_loudly(http_request)
    end
  end

  class Request < Api::ApiEntreprise::Request
    private

    # /v3/insee/sirene/etablissements
    def url_key
      @url_key ||= "insee/sirene/etablissements/"
    end
  end

  class Responder < Api::ApiEntreprise::Responder
    def format_data
      return {
        etablissement: @http_request.data["data"].merge(@http_request.data["meta"]),
        links: @http_request.data["links"],
        meta: @http_request.data["meta"]
      }
    end
  end
end
