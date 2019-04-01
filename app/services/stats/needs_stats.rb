module Stats
  class NeedsStats
    include BaseStats

    def main_query
      Need
        .diagnosis_completed
        .joins(:advisor)
        .joins(subject: :theme)
    end

    def date_group_attribute
      'needs.created_at'
    end

    def filtered(query)
      if params.territory.present?
        query.merge! Territory.find(params.territory).needs
      end
      if params.institution.present?
        query.merge! Institution.find(params.institution).sent_needs
      end

      query
    end

    def category_group_attribute
      'themes.label'
    end

    def category_order_attribute
      'themes.interview_sort_order'
    end
  end
end
