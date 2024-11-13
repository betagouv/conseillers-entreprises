module Stats::Acquisitions::Base
  def needs_main_query
    Need.diagnosis_completed
      .joins(diagnosis: { solicitation: :landing }).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def solicitations_main_query
    Solicitation.step_complete
  end

  def category_group_attribute
    :status
  end

  def count; end

  def chart
    'line-chart'
  end

  def colors
    needs_colors
  end

  def lines_colors
    %w[#c9191e #F1C40F #AFD2E9 #A8C256 #345995]
  end

  def columns_colors
    %w[#cecece #c9191e #F1C40F #AFD2E9 #A8C256 #345995]
  end
end
