# frozen_string_literal: true

module Api::Insee::Siren
  class Base < Api::Insee::Base
  end

  class Request < Api::Insee::Request
    private

    def url_key
      @url_key ||= 'siren/'
    end
  end

  class Responder < Api::Insee::Responder
    def format_data
      @http_request.data["uniteLegale"]
    end
  end
end
