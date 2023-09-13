module Stats::Mini
  class NeedsStats
    include ::Stats::Mini::BaseStats

    def main_query
      Need.joins(:diagnosis)
        .merge(Diagnosis.from_solicitation.completed)
        .with_exchange
    end
  end
end
