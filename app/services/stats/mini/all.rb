module Stats::Mini
  class All < Stats::All
    def companies_by_employees
      CompaniesByEmployeesStats.new.count
    end

    def advisors
      AdvisorsStats.new.count
    end

    def needs
      NeedsStats.new.count
    end
  end
end
