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
