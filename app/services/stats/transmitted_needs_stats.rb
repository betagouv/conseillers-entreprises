module Stats
  class TransmittedNeedsStats < NeedsStats
    def main_query
      super
        .where(diagnoses: { step: Diagnosis::LAST_STEP })
    end
  end
end
