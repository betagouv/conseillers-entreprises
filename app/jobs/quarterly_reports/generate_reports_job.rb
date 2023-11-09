class QuarterlyReports::GenerateReportsJob < ApplicationJob
  queue_as :low_priority

  def perform(antenne_id)
    antenne = Antenne.find(antenne_id)
    QuarterlyReports::GenerateReports.new(antenne).call
  end
end
