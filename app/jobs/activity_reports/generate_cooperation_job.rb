class ActivityReports::GenerateCooperationJob < ApplicationJob
  queue_as :low_priority

  def perform
    Cooperation.find_each do |cooperation|
      ActivityReports::Generate::Cooperation.perform_later(cooperation.id)
    end
  end
end
