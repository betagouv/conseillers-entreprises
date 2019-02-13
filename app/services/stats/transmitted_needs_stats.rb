module Stats
  class TransmittedNeedsStats < DiagnosedNeedsStats
    def main_query
      super
        .where(diagnoses: { step: Diagnosis::LAST_STEP })
    end
  end
end
