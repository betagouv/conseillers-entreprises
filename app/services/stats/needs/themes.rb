module Stats::Needs
  class Themes
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .joins(:advisor)
        .joins(subject: :theme)
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
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
      %w[#62e0d3 #2D908F #f3dd68 #e78112 #F45A5B #9f3cca #F15C80 #A8FF96 #946c47 #64609b #7a7a7a #CF162B]
    end
  end
end
