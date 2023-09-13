module Stats
  module FiltersStats
    def filtered_needs(query)
      query.merge! territory.needs if territory.present?
      query.merge! antenne_or_institution.perimeter_received_needs if antenne_or_institution.present?
      query.merge! Need.joins(:subject).where(subject: subject) if subject.present?
      query.merge! Need.joins(solicitation: :landing)
        .where(solicitations: { landings: { integration: integration } }) if integration.present?
      query.merge! Need.joins(solicitation: :landing)
        .where(solicitations: { landings: { id: iframe_id } }) if iframe_id.present?
      query.merge! Need.joins(subject: :theme).where(subject: { theme: theme }) if theme.present?
      if mtm_campaign.present?
        query.merge! Need.joins(:solicitation)
          .where(pk_campaign_query, "%#{mtm_campaign}%")
          .or(Need.joins(:solicitation).where(mtm_campaign_query, "%#{mtm_campaign}%"))
      end
      if mtm_kwd.present?
        query.merge! Need.joins(:solicitation)
          .where(pk_kwd_query, "%#{mtm_kwd}%")
          .or(Need.joins(:solicitation).where(mtm_kwd_query, "%#{mtm_kwd}%"))
      end
      query
    end

    def filtered_solicitations(query)
      query.merge! Solicitation.in_regions(territory.code_region) if territory.present?
      query.merge! antenne_or_institution.perimeter_received_needs if antenne_or_institution.present?
      query.merge! Solicitation.joins(landing_subject: :subject).where(subjects: subject) if subject.present?
      query.merge! Solicitation.joins(:landing).where(landings: { integration: integration }) if integration.present?
      query.merge! Solicitation.where(landing_id: iframe_id) if iframe_id.present?
      query.merge! Solicitation.joins(landing_subject: { subject: :theme }).where(subjects: { themes: theme }) if theme.present?
      if mtm_campaign.present?
        query.merge! Solicitation.where(pk_campaign_query, "%#{mtm_campaign}%")
          .or(Solicitation.where(mtm_campaign_query, "%#{mtm_campaign}%"))
      end
      if mtm_kwd.present?
        query.merge! Solicitation.where(pk_kwd_query, "%#{mtm_kwd}%")
          .or(Solicitation.where(mtm_kwd_query, "%#{mtm_kwd}%"))
      end
      query
    end

    def filtered_companies(query)
      query.merge!(territory.companies) if territory.present?
      query.merge! antenne_or_institution.perimeter_received_need if antenne_or_institution.present?
      query.merge! Company.joins(facilities: { diagnoses: { solicitation: { landing_subject: :subject } } })
        .where(landing_subjects: { subjects: subject }) if subject.present?
      query.merge! Company.joins(facilities: { diagnoses: { solicitation: :landing } })
        .where(solicitations: { landings: { integration: integration } }) if integration.present?
      query.merge! Company.joins(facilities: { diagnoses: { solicitation: { landing_subject: { subject: :theme } } } })
        .where(landing_subjects: { subjects: { theme: theme } }) if theme.present?
      if mtm_campaign.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation })
          .where(pk_campaign_query, "%#{mtm_campaign}%")
          .or(Company.joins(facilities: { diagnoses: :solicitation }).where(mtm_campaign_query, "%#{mtm_campaign}%"))
      end
      if mtm_kwd.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where(pk_kwd_query, "%#{mtm_kwd}%")
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where(mtm_kwd_query, "%#{mtm_kwd}%")
      end
      query
    end

    def filtered_matches(query)
      query = query.joins(:need)
      query.merge! query.in_region(territory) if territory.present?
      query.merge! antenne_or_institution.perimeter_received_matches if antenne_or_institution.present?
      query.merge! Match.joins(:subject).where(subjects: subject) if subject.present?
      query.merge! Match.joins(need: { solicitation: :landing })
        .where(solicitations: { landings: { integration: integration } }) if integration.present?
      query.merge! Match.joins(subject: :theme).where(subjects: { theme: theme }) if theme.present?
      if mtm_campaign.present?
        query.merge! Match.joins(need: :solicitation)
          .where(pk_campaign_query, "%#{mtm_campaign}%")
          .or(Match.joins(need: :solicitation).where(mtm_campaign_query, "%#{mtm_campaign}%"))
      end
      if mtm_kwd.present?
        query.merge! Match.joins(need: :solicitation)
          .where(pk_kwd_query, "%#{mtm_kwd}%")
          .or(Match.joins(need: :solicitation).where(mtm_kwd_query, "%#{mtm_kwd}%"))
      end
      query
    end

    private

    def antenne_or_institution
      antenne.presence || institution.presence
    end

    def pk_campaign_query
      "solicitations.form_info::json->>'pk_campaign' ILIKE ?"
    end

    def mtm_campaign_query
      "solicitations.form_info::json->>'mtm_campaign' ILIKE ?"
    end

    def pk_kwd_query
      "solicitations.form_info::json->>'pk_kwd' ILIKE ?"
    end

    def mtm_kwd_query
      "solicitations.form_info::json->>'mtm_kwd' ILIKE ?"
    end
  end
end
