module GeocoderIp
  extend ActiveSupport::Concern

  included do
    before_action :check_region
  end

  def check_region
    return if Rails.env.test?

    Rails.cache.fetch(request.remote_ip, expires_in: 12.hours) do
      ip = ENV['IP_OVERRIDE'] || request.remote_ip

      results = Rails.cache.fetch(ip, expires_in: 12.hours) do
        Geocoder.search(ip)
      end
      result_name = results.first&.region || '' # to prevent "Geocoding API error: 429 Too Many Requests"
      if result_name.present?
        current_region_code = I18n.t(result_name.parameterize, scope: 'regions_slugs_to_codes')
        session[:in_deployed_region] = Territory.deployed_codes_regions.include? current_region_code
        session[:region_code] = current_region_code
      end
    end
  end
end
