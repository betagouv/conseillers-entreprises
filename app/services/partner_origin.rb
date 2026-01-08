module PartnerOrigin
  # Helper methods for partner-specific behaviour

  # Hardcoded behaviour for Entreprendre
  ENTREPRENDRE_HOME_URL = "https://entreprendre.service-public.gouv.fr"
  ENTREPRENDRE_PAGE_BASE_URL = "#{ENTREPRENDRE_HOME_URL}/vosdroits/"
  ENTREPRENDRE_PAGE_PATTERN = /^F+[0-9]+/

  def self.from_entreprendre?(solicitation: nil, campaign: nil, kwd: nil)
    if solicitation.present?
      solicitation.cooperation&.mtm_campaign == 'entreprendre' || from_entreprendre?(campaign: solicitation.campaign, kwd: solicitation.kwd)
    elsif campaign.present? || kwd.present?
      campaign == 'entreprendre' || !!(kwd =~ ENTREPRENDRE_PAGE_PATTERN)
    else
      false
    end
  end

  def self.partner_url(solicitation, full: false)
    return if solicitation.nil?

    if solicitation.origin_url.present?
      solicitation.origin_url
    elsif (solicitation.from_entreprendre && solicitation.kwd.present?)
      entreprendre_url(solicitation, full: full)
    else
      landing_partner_url(solicitation, full: full)
    end
  end

  def self.entreprendre_url(solicitation, full: false)
    if full && (solicitation&.kwd =~ ENTREPRENDRE_PAGE_PATTERN)
      "#{ENTREPRENDRE_PAGE_BASE_URL}#{solicitation.kwd}"
    else
      ENTREPRENDRE_HOME_URL
    end
  end

  def self.landing_partner_url(solicitation, full: false)
    full ? solicitation.landing.partner_full_url : solicitation.landing.partner_url
  end
end
