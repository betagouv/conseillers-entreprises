class QueryFromEntreprendre
  def initialize(campaign: nil, kwd: nil)
    @campaign = campaign
    @kwd = kwd
  end

  def call
    entreprendre_campaign? || entreprendre_kwd?
  end

  private

  def entreprendre_campaign?
    @campaign.present? && @campaign == 'entreprendre'
  end

  def entreprendre_kwd?
    @kwd.present? && !!@kwd.match(/^F+[0-9]+/)
  end
end

module PartnerOrigin
  # Helper methods for partner origin
  # specific hardcoded behaviour for Entreprendre
  class << self

    def from_entreprendre?(solicitation: nil, campaign: nil, kwd: nil)
      if solicitation.present?
        solicitation.cooperation&.mtm_campaign == 'entreprendre' || from_entreprendre?(campaign: self.campaign, kwd: self.kwd)
      else if campaign.present? && kwd.present?
        campaign == 'entreprendre' || kwd =~ /^F+[0-9]+/
      end
      end


      def entreprendre_url(solicitation, full: false)
        full && solicitation.kwd.match(/^F+[0-9]+/) ? "https://entreprendre.service-public.gouv.fr/vosdroits/#{solicitation.kwd}" : "https://entreprendre.service-public.gouv.fr"
      end

      def landing_partner_url(solicitation, full: false)
        full ? solicitation.landing.partner_full_url : solicitation.landing.partner_url
      end

    end
end
