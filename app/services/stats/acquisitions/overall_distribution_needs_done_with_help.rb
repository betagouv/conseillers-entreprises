module Stats::Acquisitions
  class OverallDistributionNeedsDoneWithHelp
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsBase

    def main_query
      base_scope.where(status: :done)
    end

    def build_series
      build_series_for_type(chart)
    end

    def colors
      lines_colors
    end
  end
end
