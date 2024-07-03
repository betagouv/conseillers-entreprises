class CreateManagersSatisfactions < ActiveRecord::Migration[7.0]
  def up
    SharedSatisfaction.find_each do |satisfaction|
      CreateSharedSatisfactionJob.perform_later(satisfaction.company_satisfaction.id)
    end
  end
end
