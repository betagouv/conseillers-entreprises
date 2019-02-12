module Stats
  class AdvisorsStats
    include BaseStats

    def main_query
      User
        .not_admin
        .distinct
    end

    def additive_values
      true
    end

    def date_group_attribute
      'users.created_at'
    end

    def filtered(query)
      if params.territory.present?
        query.merge! Territory.find(params.territory).advisors
      end
      if params.institution.present?
        query.merge! Institution.find(params.institution).advisors
      end

      query
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('attributes.advisors.other')
    end

    def category_order_attribute
      Arel.sql('true')
    end
  end
end
