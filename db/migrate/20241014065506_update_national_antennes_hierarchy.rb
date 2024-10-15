class UpdateNationalAntennesHierarchy < ActiveRecord::Migration[7.0]
  def change
    Antenne.territorial_level_national.find_each do |antenne|
      UpdateAntenneHierarchyJob.perform_async(antenne.id)
    end
  end
end
