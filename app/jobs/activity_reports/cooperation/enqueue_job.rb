class ActivityReports::Cooperation::EnqueueJob < ApplicationJob
  queue_as :low_priority

  def perform
    Cooperation.not_archived.find_each do |cooperation|
      ActivityReports::Cooperation::GenerateJob.perform_later(cooperation.id)
    end
  end
end
