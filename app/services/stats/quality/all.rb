module Stats::Quality
  class All < Stats::All
    def needs_done
      NeedsDoneStats.new(@params)
    end
  end
end
