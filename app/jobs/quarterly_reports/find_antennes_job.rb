class QuarterlyReports::FindAntennesJob < ApplicationJob
  queue_as :low_priority

  def perform
    Antenne.find_each do |antenne|
      QuarterlyReports::GenerateReportsJob.perform_later(antenne.id)
    end
  end
end
