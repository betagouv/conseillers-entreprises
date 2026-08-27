module Stats::Acquisitions
  class OverallDistributionSolicitations
    include Stats::Acquisitions::SolicitationsBase

    def colors
      lines_colors
    end
  end
end
