# frozen_string_literal: true

module Api::Cfadock
  class Opco < Api::ApiEntreprise::Base
  end

  class Request < Api::Request
    DEFAULT_ERROR_MESSAGE = I18n.t('api_requests.default_error_message.etablissement')

    def get_url
      HTTP.get(url)
    end

    def success?
      @error.nil? && response_status.success? && @http_response.parse(:json)["searchStatus"] == "OK"
    end

    def data_error_message
      @data['searchStatus']
    end

    def api_result_key
      "opco_cfadock"
    end

    private

    def base_url
      @base_url ||= 'https://www.cfadock.fr/api/opcos?siret='
    end

    def url
      @url ||= [base_url, @query].join
    end
  end

  class Responder < Api::Responder
    def format_data
      { "effectifs_etablissement_mensuel" => @http_request.data['data'] }
    end

    def call
      { @http_request.api_result_key => @http_request.data.slice('idcc', 'opcoName', 'opcoSiren') }
    end
  end

  class CfadockError < StandardError; end
end
