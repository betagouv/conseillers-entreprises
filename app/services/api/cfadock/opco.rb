# frozen_string_literal: true

module Api::Cfadock
  class Opco < Api::ApiEntreprise::Base
    def handle_error(http_request)
      if http_request.has_tech_error?
        notify_tech_error(http_request)
      end
      return { "opco_cfadock" => { "error" => http_request.error_message } }
    end
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

    private

    def base_url
      @base_url ||= 'https://www.cfadock.fr/api/opcos?siret='
    end

    def url
      @url ||= [base_url, @siren_or_siret].join
    end
  end

  class Responder < Api::Responder
    def format_data
      { "effectifs_etablissement_mensuel" => @http_request.data['data'] }
    end

    def call
      { "opco_cfadock" => @http_request.data.slice('idcc', 'opcoName', 'opcoSiren') }
    end
  end

  class CfadockError < StandardError; end
end
