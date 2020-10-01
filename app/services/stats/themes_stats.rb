module Stats
  class ThemesStats
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
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.sent_needs
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
