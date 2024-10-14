class UpdateNationalAntennesHierarchy < ActiveRecord::Migration[7.0]
  def change
    Antenne.territorial_level_national.find_each do |antenne|
      UpdateAntenneHierarchyJob.perform_async(antenne.id)
    end

    CompanySatisfaction.shared.find_each do |company_satisfaction|
      CreateSharedSatisfactionJob.perform_later(company_satisfaction.id)
    end
  end
end
