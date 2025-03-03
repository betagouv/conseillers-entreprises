class QuarterlyReports::GenerateAntenneStatsJob < ApplicationJob
  queue_as :low_priority

  def perform
    Antenne.find_each do |antenne|
      QuarterlyReports::Generate::AntenneStats.perform_later(antenne.id)
    end
  end
end
