module Stats::Needs
  class DiagnosisCompleted
    include ::Stats::MiniStats

    def main_query
      Need.diagnosis_completed
    end
  end
end
