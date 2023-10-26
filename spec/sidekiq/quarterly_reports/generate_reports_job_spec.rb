require 'rails_helper'
RSpec.describe QuarterlyReports::GenerateReportsJob, type: :job do
  describe  do
    let(:antenne) { create(:antenne) }
    it { expect { QuarterlyReports::GenerateReportsJob.perform_async(antenne.id) }.to enqueue_sidekiq_job.with(antenne.id) }
  end
end
