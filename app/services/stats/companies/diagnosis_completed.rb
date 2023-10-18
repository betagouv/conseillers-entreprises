module Stats::Companies
  class DiagnosisCompleted
    include ::Stats::MiniStats

    def main_query
      Company
        .joins(facilities: :diagnoses)
        .where(facilities: { diagnoses: { step: :completed } })
        .distinct
    end
  end
end
