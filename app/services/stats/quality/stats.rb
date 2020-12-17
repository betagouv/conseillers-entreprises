module Stats::Quality
  class Stats < Stats::All
    def needs_done
      NeedsDoneStats.new(@params)
    end
  end
end
