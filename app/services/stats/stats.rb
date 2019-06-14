module Stats
  class Stats
    attr_reader :params

    def initialize(params = {})
      @params = OpenStruct.new(params)
    end

    def advisors
      AdvisorsStats.new(@params)
    end

    def companies
      CompaniesStats.new(@params)
    end

    def needs
      NeedsStats.new(@params)
    end

    def experts
      ExpertsStats.new(@params)
    end

    def matches
      MatchesStats.new(@params)
    end

    def solicitations
      SolicitationsStats.new(@params)
    end
  end
end
