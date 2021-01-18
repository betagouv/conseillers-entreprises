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
      current_region_name = "région #{result_name}".parameterize
      deployed_region_ids = YAML.safe_load(ENV['DEPLOYED_REGIONS_IDS'])
      deployed_regions_names = Rails.cache.fetch(deployed_region_ids) do
        Territory.where(id: deployed_region_ids)
          &.pluck(:name)
          &.map(&:parameterize)
      end
      session[:in_deployed_region] = deployed_regions_names.include? current_region_name
      session[:region] = result_name
    end
  end
end
