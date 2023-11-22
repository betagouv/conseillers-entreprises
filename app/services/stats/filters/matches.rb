module Stats::Filters
  class Matches < Base
    private

    def territories_filter(territory)
      return if territory.blank?
      # On est sure de vouloir que les régions ?
      @query.merge! @query.in_region(territory)
    end

    def antenne_or_institution_filter(antenne_or_institution)
      return if antenne_or_institution.blank?
      @query.merge! antenne_or_institution.perimeter_received_matches
    end

    def subject_filter(subject)
      return if subject.blank?
      @query.merge! Match.joins(:subject).where(subjects: subject)
    end

    def integration_filter(integration)
      return if integration.blank?
      @query.merge! Match.joins(need: { solicitation: :landing })
        .where(solicitations: { landings: { integration: integration } })
    end

    def iframe_filter(iframe_id)
      return if iframe_id.blank?
      @query.merge! Match.joins(need: { solicitation: :landing })
        .where(solicitations: { landings: { id: iframe_id } })
    end

    def theme_filter(theme)
      return if theme.blank?
      @query.merge! Match.joins(subject: :theme).where(subjects: { theme: theme })
    end

    def mtm_campaign_filter(campaign)
      return if campaign.blank?
      @query.merge! Match.joins(need: :solicitation)
        .where(pk_campaign_query, "%#{campaign}%")
        .or(Match.joins(need: :solicitation).where(mtm_campaign_query, "%#{campaign}%"))
    end

    def mtm_kwd_filter(kwd)
      return if kwd.blank?
      @query.merge! Match.joins(need: :solicitation)
        .where(pk_kwd_query, "%#{kwd}%")
        .or(Match.joins(need: :solicitation).where(mtm_kwd_query, "%#{kwd}%"))
    end
  end
end
