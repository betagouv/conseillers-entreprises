module Stats
  class SourceStats
    include BaseStats

    def main_query
      Diagnosis
        .completed
        .joins(:advisor_institution)
    end

    def date_group_attribute
      'diagnoses.created_at'
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.diagnoses
      end
      if institution.present?
        query.merge! institution.sent_diagnoses
      end

      query
    end

    def category_group_attribute
      # Once we actually join the Solicitation and Diagnosis,
      # we’ll be able to properly query if a Diagnosis came from a Solicitation.
      # In the meantime, we’ll just see if the advisor was from the DINUM.
      Arel.sql("institutions.name = 'DINUM'")
    end

    def category_name(category)
      # category is a bool, result of the category_group_attribute comparison
      category ? I18n.t('stats.series.source.direct') : I18n.t('stats.series.source.visits')
    end

    def category_order_attribute
      category_group_attribute
    end
  end
end
