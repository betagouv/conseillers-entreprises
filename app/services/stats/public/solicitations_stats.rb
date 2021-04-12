module Stats::Public
  class SolicitationsStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      if territory.present?
        query.merge! Solicitation.in_regions(territory.code_region)
      end
      if institution.present?
        query.merge! institution.received_solicitations
      end
      query
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('stats.series.solicitations.series')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def chart
      'stats-chart'
    end
  end
end
