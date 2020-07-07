module GeocoderIp
  extend ActiveSupport::Concern

  included do
    before_action :check_region
  end

  def check_region
    return if Rails.env.test?

    ip = ENV['IP_OVERRIDE'] || request.remote_ip
    if session[:region].blank?
      results = Rails.cache.fetch(ip, expires_in: 12.hours) do
        Geocoder.search(ip)
      end
      region = results.first&.region || '' # to prevent "Geocoding API error: 429 Too Many Requests"
      session[:region] = region
    end
  end
end
