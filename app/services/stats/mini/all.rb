module Stats::Mini
  class All < Stats::All
    def companies_by_employees
      CompaniesByEmployeesStats.new(@params)
    end

    def advisors
      AdvisorsStats.new(@params)
    end

    def needs
      NeedsStats.new(@params)
    end
  end
end
