module Stats::Needs
  class Themes
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
      I18n.t('stats.series.needs_themes.subtitle')
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

    def colors
      %w[#9F3BCA #F15C80 #E78016 #F2DD68 #2D908F #62E0D3 #88c479 #A7FF96 #946D47 #64609B #63DDDB #F45A5A]
    end
  end
end
