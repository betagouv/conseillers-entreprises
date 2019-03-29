module Stats
  class DiagnosedNeedsStats
    include BaseStats

    def main_query
      DiagnosedNeed
        .joins(:advisor)
        .joins(question: :theme)
    end

    def date_group_attribute
      'diagnosed_needs.created_at'
    end

    def filtered(query)
      if params.territory.present?
        query.merge! Territory.find(params.territory).diagnosed_needs
      end
      if params.institution.present?
        query.merge! Institution.find(params.institution).sent_diagnosed_needs
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
