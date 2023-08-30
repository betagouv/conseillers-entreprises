module Stats::Manager
  class All < Stats::All
    def needs_transmitted
      Stats::Needs::TransmittedNeedsStats.new(@params)
    end

    def positioning_rate
      Stats::Matches::PositioningRate.new(@params)
    end

    def not_positioning_rate
      Stats::Matches::NotPositioningRate.new(@params)
    end

    def taking_care_rate_stats
      Stats::Matches::TakingCareRateStats.new(@params)
    end

    def done_rate_stats
      Stats::Matches::DoneRateStats.new(@params)
    end

    def done_no_help_rate_stats
      Stats::Matches::DoneNoHelpRateStats.new(@params)
    end

    def done_not_reachable_rate_stats
      Stats::Matches::DoneNotReachableRateStats.new(@params)
    end

    def not_for_me_rate_stats
      Stats::Matches::NotForMeRateStats.new(@params)
    end
  end
end
