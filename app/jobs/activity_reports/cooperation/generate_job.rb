class ActivityReports::Cooperation::GenerateJob < ApplicationJob
  queue_as :low_priority

  def perform(antenne_id)
    antenne = Antenne.find(antenne_id)
    ActivityReports::Generate::Cooperation.new(antenne).call
  end
end
