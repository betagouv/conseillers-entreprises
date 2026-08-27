module Stats::Acquisitions
  class OverallDistributionNeedsTransmitted
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsBase

    def main_query
      base_scope
    end

    def colors
      lines_colors
    end
  end
end
