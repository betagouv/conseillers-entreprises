module Stats
  class NeedsStats
    include BaseStats

    def main_query
      Need.diagnosis_completed
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
      if @start_date.present?
        query.where!(needs: { created_at: @start_date..@end_date })
      end
      query
    end

    def category_name(category)
      I18n.t('activerecord.models.need.other')
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_order_attribute
      Arel.sql('true')
    end
  end
end
