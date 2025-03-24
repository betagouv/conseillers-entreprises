class ActivityReports::AntenneStats::EnqueueJob < ApplicationJob
  queue_as :low_priority

  def perform
    Antenne.find_each do |antenne|
      ActivityReports::AntenneStats::GenerateJob.perform_later(antenne.id)
    end
  end
end
