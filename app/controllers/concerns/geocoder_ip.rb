module GeocoderIp
  extend ActiveSupport::Concern

  included do
    before_action :check_region
  end

  def check_region
    return if Rails.env.test?

    ip = ENV['IP_OVERRIDE'] || request.remote_ip
    if session[:in_deployed_region].blank?
      results = Rails.cache.fetch(ip, expires_in: 12.hours) do
        Geocoder.search(ip)
      end
      result_name = results.first&.region || '' # to prevent "Geocoding API error: 429 Too Many Requests"
      current_region_code = I18n.t(result_name.parameterize, scope: 'regions_slugs_to_codes')
      session[:in_deployed_region] = Territory.deployed_code_regions.include? current_region_code
      session[:region_code] = current_region_code
    end
  end
end
