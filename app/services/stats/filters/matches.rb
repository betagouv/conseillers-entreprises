module Stats::Filters
  class Matches < Base
    private

    def territories_filter(territory_id)
      territory = Territory.find_by(id: territory_id)
      return if territory.blank?
      @query.merge! @query.in_region(territory)
    end

    def antenne_or_institution_filter(antenne_or_institution, with_agglomerate_data)
      return if antenne_or_institution.blank?
      if !with_agglomerate_data || antenne_or_institution.is_a?(Institution)
        @query.merge! antenne_or_institution.received_matches_including_from_deleted_experts
      else
        @query.merge! antenne_or_institution.perimeter_received_matches
      end
    end

    def subject_filter(subject)
      return if subject.blank?
      @query.merge! Match.joins(:subject).where(subject: subject)
    end

    def integration_filter(integration)
      return if integration.blank?
      @query.merge! Match.joins(need: { solicitation: :landing })
        .where(solicitations: { landings: { integration: integration } })
    end

    def cooperation_filter(cooperation_id)
      return if cooperation_id.blank?
      @query.merge! Match.joins(need: { solicitation: :cooperation })
        .where(solicitations: { cooperations: { id: cooperation_id } })
    end

    def landing_filter(landing_id)
      return if landing_id.blank?
      @query.merge! Match.joins(need: { solicitation: :landing })
        .where(solicitations: { landings: { id: landing_id } })
    end

    def theme_filter(theme)
      return if theme.blank?
      @query.merge! Match.joins(subject: :theme).where(subjects: { theme: theme })
    end

    def provenance_detail_filter(provenance_detail)
      return if provenance_detail.blank?
      @query.merge! Match.joins(need: :solicitation)
        .where(solicitations: { provenance_detail: provenance_detail })
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
