module Stats::Team
  class Needs < Stats::All
    def needs_quo
      Stats::Needs::NeedsQuoStats.new(@params)
    end

    def needs_done
      Stats::Needs::NeedsDoneStats.new(@params)
    end

    def needs_done_no_help
      Stats::Needs::NeedsDoneNoHelpStats.new(@params)
    end

    def needs_done_not_reachable
      Stats::Needs::NeedsDoneNotReachableStats.new(@params)
    end

    def needs_not_for_me
      Stats::Needs::NeedsNotForMeStats.new(@params)
    end

    def needs_abandoned
      Stats::Needs::NeedsAbandonedStats.new(@params)
    end

    def transmitted_less_than_72h_stats
      Stats::Solicitations::TransmittedLessThan72hStats.new(@params)
    end
  end
end
