module Stats::Public
  class All < Stats::All
    def companies_by_employees
      CompaniesByEmployeesStats.new(@params)
    end

    def themes
      ThemesStats.new(@params)
    end

    def experts
      ExpertsStats.new(@params)
    end

    def solicitations_diagnoses
      SolicitationsDiagnosesStats.new(@params)
    end

    def solicitations
      SolicitationsStats.new(@params)
    end

    def taking_care
      TakingCareTimeStats.new(@params)
    end

    def companies_by_naf_code
      CompaniesByNafCodeStats.new(@params)
    end

    def exchange_with_expert
      ExchangeWithExpertStats.new(@params)
    end

    # def solicitations_in_regions
    #   SolicitationsInRegionsStats.new(@params)
    # end
  end
end
