class ActivityReports::AntenneMatches::GenerateJob < ApplicationJob
  queue_as :low_priority

  def perform(antenne_id)
    antenne = Antenne.find(antenne_id)
    ActivityReports::Generate::AntenneMatches.new(antenne).call
  end
end
