module Stats::Mini
  class AdvisorsStats
    include ::Stats::Mini::BaseStats

    def main_query
      User.active.distinct
    end
  end
end
