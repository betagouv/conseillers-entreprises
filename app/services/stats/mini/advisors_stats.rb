module Stats::Mini
  class AdvisorsStats
    include ::Stats::Mini::BaseStats

    def main_query
      User.distinct
    end
  end
end
