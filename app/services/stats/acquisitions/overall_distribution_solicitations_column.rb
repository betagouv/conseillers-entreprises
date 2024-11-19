module Stats::Acquisitions
  class OverallDistributionSolicitationsColumn
    include Stats::Acquisitions::SolicitationsBase

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
