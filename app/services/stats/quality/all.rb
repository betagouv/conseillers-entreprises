module Stats::Quality
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
  end
end
