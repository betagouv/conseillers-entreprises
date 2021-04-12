module Stats::Public
  class CompaniesByNafCodeStats
    include ::Stats::BaseStats

    def main_query
      Company
        .includes(:needs).references(:needs)
        .where(needs: { created_at: @start_date..@end_date })
        .where(facilities: { diagnoses: { step: :completed } })
        .distinct
    end

    def date_group_attribute
      'diagnoses.created_at'
    end

    def filtered(query)
      if territory.present?
        query.merge!(territory.companies)
      end
      if institution.present?
        query.where!(diagnoses: institution.received_diagnoses)
      end
      query
    end

    def category_group_attribute
      'facilities.naf_code_a10'
    end

    def category_order_attribute
      'facilities.naf_code_a10'
    end

    def colors
      %w[#DDDDDD #9F3BCA #F15C80 #E78016 #F2DD68 #2D908F #62E0D3 #88c479 #A7FF96 #946D47 #64609B #63DDDB #F45A5A]
    end

    def count
      false
    end

    def category_name(category)
      NafCode::libelle_a10(category)
    end

    def all_categories
      super
      # Put "no data" on the first position to be at the top of the graph
      @all_categories.insert(0, @all_categories.delete(nil))
    end
  end
end
