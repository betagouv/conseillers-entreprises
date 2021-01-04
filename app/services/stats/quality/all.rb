module Stats::Quality
  class All < Stats::All
    def needs_done
      NeedsDoneStats.new(@params)
    end

    def needs_done_no_help
      NeedsDoneNoHelpStats.new(@params)
    end
  end
end
