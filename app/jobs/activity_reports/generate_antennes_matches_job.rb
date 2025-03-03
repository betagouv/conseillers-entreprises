class ActivityReports::GenerateAntennesMatchesJob < ApplicationJob
  queue_as :low_priority

  def perform
    Antenne.find_each do |antenne|
      ActivityReports::Generate::AntenneMatches.perform_later(antenne.id)
    end
  end
end
