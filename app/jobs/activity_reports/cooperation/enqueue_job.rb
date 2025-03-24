class ActivityReports::Cooperation::EnqueueJob < ApplicationJob
  queue_as :low_priority

  def perform
    Antenne.find_each do |antenne|
      ActivityReports::Cooperation::GenerateJob.perform_later(antenne.id)
    end
  end
end
