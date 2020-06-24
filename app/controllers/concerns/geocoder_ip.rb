module GeocoderIp
  extend ActiveSupport::Concern

  included do
    before_action :check_region
  end

  def check_region
    return if Rails.env.test?

    ip = ENV['IP_OVERRIDE'] || request.remote_ip
    if session[:region_in_territory].blank?
      results = Rails.cache.fetch(ip, expires_in: 12.hours) do
        Geocoder.search(ip)
      end
      region = results.first&.region || '' # to prevent "Geocoding API error: 429 Too Many Requests"
      all_regions = ["Hauts-de-France"]
      unless all_regions.include? region
        session[:region_in_territory] = t('pages.alert_region.alert_region_html')
      end
    end
  end
end
