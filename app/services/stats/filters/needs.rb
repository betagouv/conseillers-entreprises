module Stats::Filters
  class Needs < Base
    private

    def territories_filter(territory)
      return if territory.blank?
      @query.merge! territory.needs
    end

    def antenne_or_institution_filter(antenne_or_institution, is_local_antenne)
      return if antenne_or_institution.blank?
      if is_local_antenne || antenne_or_institution.is_a?(Institution)
        @query.merge! antenne_or_institution.received_needs_including_from_deleted_experts
      else
        @query.merge! antenne_or_institution.perimeter_received_needs
      end
    end

    def subject_filter(subject)
      return if subject.blank?
      @query.merge! Need.joins(:subject).where(subject: subject)
    end

    def integration_filter(integration)
      return if integration.blank?
      @query.merge! Need.joins(solicitation: :landing)
        .where(solicitations: { landings: { integration: integration } })
    end

    def iframe_filter(iframe_id)
      return if iframe_id.blank?
      @query.merge! Need.joins(solicitation: :landing)
        .where(solicitations: { landings: { id: iframe_id } })
    end

    def theme_filter(theme)
      return if theme.blank?
      @query.merge! Need.joins(subject: :theme).where(subject: { theme: theme })
    end

    def mtm_campaign_filter(mtm_campaign)
      return if mtm_campaign.blank?
      @query.merge! Need.joins(:solicitation)
        .where(pk_campaign_query, "%#{mtm_campaign}%")
        .or(Need.joins(:solicitation).where(mtm_campaign_query, "%#{mtm_campaign}%"))
    end

    def mtm_kwd_filter(mtm_kwd)
      return if mtm_kwd.blank?
      @query.merge! Need.joins(:solicitation)
        .where(pk_kwd_query, "%#{mtm_kwd}%")
        .or(Need.joins(:solicitation).where(mtm_kwd_query, "%#{mtm_kwd}%"))
    end
  end
end
