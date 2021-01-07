module Stats::Mini
  class AdvisorsStats
    include ::Stats::BaseStats

    def main_query
      User.all.distinct
    end
  end
end
