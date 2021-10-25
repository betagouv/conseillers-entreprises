# frozen_string_literal: true

module ApiCfadock
  class GetOpco
    def self.call(siret)
      begin
        http_response = Query.call(siret)
        QueryFilter.new(http_response)
      rescue CfadockError
        return nil
      end
    end
  end

  class Query
    BASE_URL = 'https://www.cfadock.fr/api/opcos?siret='

    def self.call(siret)
      clean_siret = FormatSiret.clean_siret(siret)
      raise CfadockError unless FormatSiret.siret_is_valid(clean_siret)

      url = [BASE_URL, clean_siret].join

      http_response = HTTP.get(url)
      http_response.parse(:json)
    end
  end

  class QueryFilter
    attr_accessor :data

    def initialize(http_response)
      raise CfadockError unless http_response['searchStatus'] == "OK"
      # On ne garde que les champs qui nous intéresse
      @data = http_response.slice('idcc', 'opcoName', 'opcoSiren')
    end
  end

  class CfadockError < StandardError; end
end
