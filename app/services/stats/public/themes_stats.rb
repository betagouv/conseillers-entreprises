module Stats::Public
  class ThemesStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need
        .diagnosis_completed
        .joins(:advisor)
        .joins(subject: :theme)
        .where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      filtered_needs(query)
    end

    def subtitle
      I18n.t('stats.series.themes.subtitle')
    end

    def category_group_attribute
      'themes.label'
    end

    def category_order_attribute
      'themes.interview_sort_order'
    end

    def count
      false
    end
  end
end
