# frozen_string_literal: true

module FirmapiService
  def self.search_companies(name:, county:)
    firmapi_url = "https://firmapi.com/api/v1/companies?name=#{name}&department=#{county}"
    firmapi_json = JSON.parse open(firmapi_url).read
    firmapi_json = nil unless firmapi_json['status'] == 'success'
    firmapi_json
  rescue OpenURI::HTTPError
    Rails.logger.error 'Firmapi HTTPError'
    nil
  end
end
