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
      if @start_date.present?
        query = query.where("needs.created_at >= ? AND needs.created_at <= ?", @start_date, @end_date)
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
