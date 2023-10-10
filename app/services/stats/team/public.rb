module Stats::Team
  class Public < Stats::All
    def companies_by_employees
      Stats::Companies::CompaniesByEmployeesStats.new(@params)
    end

    def themes
      Stats::Needs::ThemesStats.new(@params)
    end

    def solicitations_diagnoses
      Stats::Solicitations::SolicitationsDiagnosesStats.new(@params)
    end

    def solicitations
      Stats::Solicitations::SolicitationsStats.new(@params)
    end

    def taking_care
      Stats::Solicitations::TakingCareTimeStats.new(@params)
    end

    def companies_by_naf_code
      Stats::Companies::CompaniesByNafCodeStats.new(@params)
    end

    def exchange_with_expert
      Stats::Needs::ExchangeWithExpertStats.new(@params)
    end

    def needs_done_from_exchange
      Stats::Needs::NeedsDoneStats.new(@params)
    end
  end
end
