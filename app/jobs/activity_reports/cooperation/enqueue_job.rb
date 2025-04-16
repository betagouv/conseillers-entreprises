class ActivityReports::Cooperation::EnqueueJob < ApplicationJob
  queue_as :low_priority

  def perform
    Cooperation.find_each do |cooperation|
      ActivityReports::Cooperation::GenerateJob.perform_later(cooperation.id)
    end
  end
end
