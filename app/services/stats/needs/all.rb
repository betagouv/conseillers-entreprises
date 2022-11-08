module Stats::Needs
  class All < Stats::All
    def needs_done
      NeedsDoneStats.new(@params)
    end

    def needs_done_no_help
      NeedsDoneNoHelpStats.new(@params)
    end

    def needs_done_not_reachable
      NeedsDoneNotReachableStats.new(@params)
    end

    def needs_not_for_me
      NeedsNotForMeStats.new(@params)
    end

    def needs_abandoned
      NeedsAbandonedStats.new(@params)
    end

    def transmitted_less_than_72h_stats
      TransmittedLessThan72hStats.new(@params)
    end
  end
end
