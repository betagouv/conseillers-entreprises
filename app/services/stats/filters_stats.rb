module Stats
  module FiltersStats
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
