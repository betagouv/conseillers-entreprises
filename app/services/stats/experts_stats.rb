module Stats
  class ExpertsStats
    include BaseStats

    def main_query
      Expert.all.distinct
    end

    def additive_values
      true
    end

    def date_group_attribute
      'experts.created_at'
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
  end
end
