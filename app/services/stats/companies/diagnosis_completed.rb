module Stats::Companies
  class DiagnosisCompleted
    include ::Stats::MiniStats

    def main_query
      diagnosis_done = Diagnosis.from_solicitation
        .joins(:needs).merge(Need.status_done)
      Company
        .joins(facilities: :diagnoses)
        .where(facilities: { diagnoses: diagnosis_done })
        .distinct
    end
  end
end
