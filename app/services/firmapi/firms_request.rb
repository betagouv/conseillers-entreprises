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
      http_response = connection.get(root_url, params: { name: name, department: county })
      FirmsResponse.new(http_response)
    end

    def root_url
      'https://firmapi.com/api/v1/companies'
    end
  end
end
