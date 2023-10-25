class QuarterlyReports::FindAntennesJob
  include Sidekiq::Job
  sidekiq_options queue: 'low_priority'

  def perform
    Antenne.find_each do |antenne|
      QuarterlyReports::GenerateReportsJob.perform_async(antenne.id)
    end
  end
end
