module PartnerOrigin
  # Helper methods for partner-specific behaviour

  # Hardcoded behaviour for Entreprendre
  ENTREPRENDRE_HOME_URL = "https://entreprendre.service-public.gouv.fr"
  ENTREPRENDRE_PAGE_BASE_URL = "#{ENTREPRENDRE_HOME_URL}/vosdroits/"
  ENTREPRENDRE_PAGE_PATTERN = /^F+[0-9]+/

  def self.from_entreprendre?(solicitation: nil, campaign: nil, kwd: nil)
    if solicitation.present?
      solicitation.cooperation&.mtm_campaign == 'entreprendre' || from_entreprendre?(campaign: self.campaign, kwd: self.kwd)
    elsif campaign.present? || kwd.present?
      campaign == 'entreprendre' || !!(kwd =~ ENTREPRENDRE_PAGE_PATTERN)
    else
      false
    end
  end
end
