module Stats
  module FiltersStats
    def filtered_needs(query)
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      if iframe.present?
        query.merge! Need.joins(solicitation: :landing).where(solicitations: { landings: iframe })
      end
      query
    end

    def filtered_solicitations(query)
      if territory.present?
        query.merge! Solicitation.in_regions(territory.code_region)
      end
      if institution.present?
        query.merge! institution.received_solicitations
      end
      if iframe.present?
        query.merge! Solicitation.joins(:landing).where(landings: iframe)
      end
      query
    end

    def filtered_companies(query)
      if territory.present?
        query.merge!(territory.companies)
      end
      if institution.present?
        query.where!(diagnoses: institution.received_diagnoses)
      end
      if iframe.present?
        query.merge! Company.joins(facilities: { diagnoses: :solicitation }).where(solicitations: { landings: iframe })
      end
      query
    end
  end
end
