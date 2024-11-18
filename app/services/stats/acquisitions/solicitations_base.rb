module Stats::Acquisitions::SolicitationsBase
  include ::Stats::BaseStats
  include Stats::Acquisitions::Base

  def main_query
    Solicitation.step_complete
  end

  def base_scope
    Need.diagnosis_completed
      .joins(diagnosis: { solicitation: :landing }).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
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
