module Stats::Acquisitions
  class OverallDistributionNeedsDoneWithHelpColumn
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsBase

    def main_query
      base_scope.where(status: :done)
    end

    def build_series
      build_series_for_type(chart)
    end

    def colors
      columns_colors
    end

    def chart
      'percentage-column-chart'
    end
  end
end
