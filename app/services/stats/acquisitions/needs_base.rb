module Stats::Acquisitions::NeedsBase
  include Stats::Acquisitions::Base

  def base_scope
    Need.diagnosis_completed
      .joins(diagnosis: { solicitation: :landing }).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def filtered(query)
    Stats::Filters::Needs.new(query, self).call
  end

  private

  def as_series(results)
    results.map do |key, value|
      {
        name: I18n.t("stats.series.#{key}.title"),
        data: value
      }
    end
  end
end
