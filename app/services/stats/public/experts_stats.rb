module Stats::Public
  class ExpertsStats
    include ::Stats::BaseStats

    def main_query
      Expert.distinct
    end

    def additive_values
      true
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.antenne_experts
      end
      if institution.present?
        query.merge! institution.experts
      end

      query
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('attributes.experts.other')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def chart
      'stats-chart'
    end

    # def format
    #   '{series.name} : <b>{point.y}</b> ({point.percentage:.0f}%)<br>Total: {point.stackTotal}'
    # end
  end
end
