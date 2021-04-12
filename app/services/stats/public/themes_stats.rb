module Stats::Public
  class ThemesStats
    include ::Stats::BaseStats

    def main_query
      Need
        .diagnosis_completed
        .joins(:advisor)
        .joins(subject: :theme)
        .where("needs.created_at >= ? AND needs.created_at <= ?", @start_date, @end_date)
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      query
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
