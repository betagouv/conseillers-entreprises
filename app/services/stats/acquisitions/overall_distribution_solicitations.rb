module Stats::Acquisitions
  class OverallDistributionSolicitations
    include Stats::Acquisitions::SolicitationsBase

    def build_series
      build_series_for_type(chart)
    end

    def colors
      lines_colors
    end
  end
end
