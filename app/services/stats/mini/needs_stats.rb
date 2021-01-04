module Stats::Mini
  class NeedsStats
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
    end
  end
end
