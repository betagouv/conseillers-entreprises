module Stats::Acquisitions
  class OverallDistributionNeedsTransmitted
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsBase

    def main_query
      base_scope
    end

    def build_series
      build_series_for_type(chart)
    end

    def colors
      lines_colors
    end
  end
end
