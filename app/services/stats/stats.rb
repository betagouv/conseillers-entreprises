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

    def themes
      ThemesStats.new(@params)
    end

    def experts
      ExpertsStats.new(@params)
    end

    def matches
      MatchesStats.new(@params)
    end

    def solicitations_diagnoses
      SolicitationsDiagnosesStats.new(@params)
    end

    def solicitations
      SolicitationsStats.new(@params)
    end

    def source
      SourceStats.new(@params)
    end

    def public_companies
      PublicCompaniesStats.new(@params)
    end

    def taking_care
      PublicTakingCareStats.new(@params)
    end

    def exchange_with_expert
      ExchangeWithExpertStats.new(@params)
    end
  end
end
