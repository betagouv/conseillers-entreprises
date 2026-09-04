module Stats::Acquisitions
  class OverallDistributionSolicitationsColumn
    include Stats::Acquisitions::SolicitationsBase

    def colors
      columns_colors
    end

    def chart
      'percentage-column-chart'
    end
  end
end
