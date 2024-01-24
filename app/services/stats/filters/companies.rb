module Stats::Filters
  class Companies < Base
    private

    def territories_filter(territory)
      return if territory.blank?
      @query.merge! territory.companies
    end

    def antenne_or_institution_filter(antenne_or_institution, with_agglomerate_data)
      return if antenne_or_institution.blank?
      if !with_agglomerate_data || antenne_or_institution.is_a?(Institution)
        @query.merge! Company.joins(facilities: :needs).where(needs: antenne_or_institution.received_needs_including_from_deleted_experts)
      else
        @query.merge! Company.joins(facilities: :needs).where(needs: antenne_or_institution.perimeter_received_needs)
      end
    end

    def subject_filter(subject)
      return if subject.blank?
      @query.merge! Company.joins(facilities: { diagnoses: { solicitation: { landing_subject: :subject } } })
        .where(landing_subjects: { subjects: subject })
    end

    def integration_filter(integration)
      return if integration.blank?
      @query.merge! Company.joins(facilities: { diagnoses: { solicitation: :landing } })
        .where(landing: { integration: integration })
    end

    def iframe_filter(iframe_id)
      return if iframe_id.blank?
      @query.merge! Company.joins(facilities: { diagnoses: { solicitation: :landing } })
        .where(landing: { id: iframe_id })
    end

    def theme_filter(theme)
      return if theme.blank?
      @query.merge! Company.joins(facilities: { diagnoses: { solicitation: { landing_subject: { subject: :theme } } } })
        .where(subjects: { theme: theme })
    end

    def mtm_campaign_filter(campaign)
      return if campaign.blank?
      @query.merge! Company.joins(facilities: { diagnoses: :solicitation })
        .where(pk_campaign_query, "%#{campaign}%")
        .or(Company.joins(facilities: { diagnoses: :solicitation }).where(mtm_campaign_query, "%#{campaign}%"))
    end

    def mtm_kwd_filter(kwd)
      return if kwd.blank?
      @query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where(pk_kwd_query, "%#{kwd}%")
        .or(Company.joins(facilities: { diagnoses: :solicitation }).where(mtm_kwd_query, "%#{kwd}%"))
    end
  end
end
