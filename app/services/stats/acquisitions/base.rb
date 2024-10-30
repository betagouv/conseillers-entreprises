module Stats::Acquisitions::Base
  def main_query
    needs_base_scope
      .joins(diagnosis: :solicitation)
  end

  def needs_base_scope
    Need.diagnosis_completed
      .joins(:diagnosis).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def category_group_attribute
    :status
  end

  def chart
    'line-chart'
  end

  def colors
    needs_colors
  end
end
