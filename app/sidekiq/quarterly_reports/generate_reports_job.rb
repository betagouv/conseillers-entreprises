class QuarterlyReports::GenerateReportsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform(antenne_id)
    antenne = Antenne.find(antenne_id)
    QuarterlyReports::GenerateReports.new(antenne).call
  end
end
