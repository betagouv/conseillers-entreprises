module Stats::Mini
  class CompaniesByEmployeesStats
    include ::Stats::Mini::BaseStats

    def main_query
      Company
        .includes(:needs).references(:needs)
        .where(facilities: { diagnoses: { step: :completed } })
        .where(facilities: { needs: { status: :done } })
        .distinct
    end
  end
end
