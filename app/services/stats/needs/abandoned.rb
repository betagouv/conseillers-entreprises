module Stats::Needs
  class Abandoned
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .with_action(:abandon)
    end

    def category_group_attribute
      :status
    end

    def category_order_attribute
      :status
    end

    def category_name(category)
      Need.human_attribute_value(:status, category)
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    def count
      ''
    end

    def secondary_count
      filtered(main_query).size
    end

    def subtitle
      I18n.t('stats.series.needs_abandoned.subtitle')
    end
  end
end
