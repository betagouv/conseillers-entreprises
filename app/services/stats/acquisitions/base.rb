module Stats::Acquisitions::Base
  def needs_base_scope
    Need.diagnosis_completed
      .joins(:diagnosis).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def category_group_attribute
    :status
  end
end
