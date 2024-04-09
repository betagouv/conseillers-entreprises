module Stats::Needs::Base
  def needs_base_scope
    Need.diagnosis_completed
      .joins(:diagnosis).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end
end
