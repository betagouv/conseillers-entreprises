module Stats::Needs::Base
  def needs_base_scope
    Need.diagnosis_completed
      .joins(:diagnosis).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def main_query
    needs_base_scope
  end

  def filtered_main_query
    Stats::Filters::Needs.new(main_query, self).call
  end
end
