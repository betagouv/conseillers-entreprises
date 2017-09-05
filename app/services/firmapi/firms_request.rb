# frozen_string_literal: true

module Firmapi
  class FirmsRequest
    attr_reader :name, :county, :connection

    def initialize(name, county, connection)
      @name = name
      @county = county
      @connection = connection
    end

    def response
      http_response = connection.get(url)
      FirmsResponse.new(http_response)
    end

    def url
      "https://firmapi.com/api/v1/companies?name=#{name}&department=#{county}"
    end
  end
end
