class ActivityReports::AntenneStats::GenerateJob < ApplicationJob
  queue_as :low_priority

  def perform(antenne_id)
    antenne = Antenne.find(antenne_id)
    ActivityReports::Generate::AntenneStats.new(antenne).call
  end
end
