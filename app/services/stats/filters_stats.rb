module Stats
  module FiltersStats
    def filtered_companies(query)
      query.merge!(territory.companies) if territory.present?
      query.merge! Company.joins(facilities: :needs).where(needs: antenne_or_institution.perimeter_received_needs) if antenne_or_institution.present?
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
  end
end
