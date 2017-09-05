# frozen_string_literal: true

module Firmapi
  class FirmsSearch
    def initialize; end

    def fetch(name, county)
      Rails.cache.fetch("firmapi-#{name}-#{county}", expires_in: 12.hours) do
        fetch_from_api(name, county)
      end
    end

    def fetch_from_api(name, county)
      connection = HTTP

      firms_response = FirmsRequest.new(name, county, connection).response
      raise FirmapiError, firms_response.error_message unless firms_response.success?

      firms_response.firms
    end
  end
end
