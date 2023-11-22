module Stats::Filters
  class Solicitations < Base
    private

    def territories_filter(territory)
      return if territory.blank?
      @query.merge! Solicitation.in_regions(territory.code_region)
    end

    def antenne_or_institution_filter(antenne_or_institution)
      return if antenne_or_institution.blank?
      @query.merge! antenne_or_institution.received_solicitations_including_from_deleted_experts
    end

    def subject_filter(subject)
      return if subject.blank?
      @query.merge! Solicitation.joins(landing_subject: :subject).where(subjects: subject)
    end

    def integration_filter(integration)
      return if integration.blank?
      @query.merge! Solicitation.joins(:landing).where(landings: { integration: integration })
    end

    def iframe_filter(iframe_id)
      return if iframe_id.blank?
      @query.merge! Solicitation.where(landing_id: iframe_id)
    end

    def theme_filter(theme)
      return if theme.blank?
      @query.merge! Solicitation.joins(landing_subject: { subject: :theme }).where(subjects: { themes: theme })
    end

    def mtm_campaign_filter(mtm_campaign)
      return if mtm_campaign.blank?
      @query.merge! Solicitation.where(pk_campaign_query, "%#{mtm_campaign}%")
        .or(Solicitation.where(mtm_campaign_query, "%#{mtm_campaign}%"))
    end

    def mtm_kwd_filter(mtm_kwd)
      return if mtm_kwd.blank?
      @query.merge! Solicitation.where(pk_kwd_query, "%#{mtm_kwd}%")
        .or(Solicitation.where(mtm_kwd_query, "%#{mtm_kwd}%"))
    end
  end
end
