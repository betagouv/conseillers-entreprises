module Stats
  module FiltersStats
    def filtered_needs(query)
      query.merge! territory.needs if territory.present?
      query.merge! institution.received_needs if institution.present?
      query.merge! Need.joins(solicitation: :landing).where(solicitations: { landings: iframe }) if iframe.present?
      if pk_campaign.present?
        query.merge! Need.joins(:solicitation).where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{pk_campaign}%")
      end
      if pk_kwd.present?
        query.merge! Need.joins(:solicitation).where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{pk_kwd}%")
      end
      query
    end

    def filtered_solicitations(query)
      query.merge! Solicitation.in_regions(territory.code_region) if territory.present?
      query.merge! institution.received_solicitations if institution.present?
      query.merge! Solicitation.joins(:landing).where(landings: iframe) if iframe.present?
      if pk_campaign.present?
        query.merge! Solicitation.where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{pk_campaign}%")
      end
      if pk_kwd.present?
        query.merge! Solicitation.where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{pk_kwd}%")
      end
      query
    end

    def filtered_companies(query)
      query.merge!(territory.companies) if territory.present?
      query.where!(diagnoses: institution.received_diagnoses) if institution.present?
      if iframe.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where(solicitations: { landings: iframe })
      end
      if pk_campaign.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{pk_campaign}%")
      end
      if pk_kwd.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{pk_kwd}%")
      end
      query
    end
  end
end
