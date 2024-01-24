module Stats::Companies
  class ByNafCode
    include ::Stats::BaseStats

    def main_query
      Company
        .includes(:needs, :diagnoses).references(:needs, :diagnoses)
        .where(facilities: { diagnoses: { step: :completed, created_at: @start_date..@end_date } })
    end

    def date_group_attribute
      'diagnoses.created_at'
    end

    def filtered(query)
      Stats::Filters::Companies.new(query, self).call
    end

    def category_group_attribute
      'facilities.naf_code_a10'
    end

    def category_order_attribute
      'facilities.naf_code_a10'
    end

    def grouped_by_month(query)
      query.group("DATE_TRUNC('month', diagnoses.created_at)")
    end

    def colors
      %w[#DDDDDD #9F3BCA #F15C80 #E78016 #F2DD68 #2D908F #62E0D3 #88c479 #A7FF96 #946D47 #64609B #DDDDDD #F45A5A]
    end

    def count
      false
    end

    def category_name(category)
      NafCode.naf_libelle(category, 'a10')
    end

    def all_categories
      super
      # Put "no data" on the first position to be at the top of the graph
      @all_categories.insert(0, @all_categories.delete(nil))
    end
  end
end
