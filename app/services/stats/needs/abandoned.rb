module Stats::Needs
  class Abandoned
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
        .joins(:diagnosis).merge(Diagnosis.from_solicitation)
        .with_action(:abandon)
        .where(created_at: @start_date..@end_date)
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
      total = filtered(Need.diagnosis_completed
      .joins(:diagnosis).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date))
      total == 0 ? "0" : "#{(secondary_count * 100).fdiv(total.size).round}%"
    end

    def secondary_count
      filtered(main_query).size
    end
  end
end
