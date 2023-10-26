require 'rails_helper'
RSpec.describe QuarterlyReports::NotifyManagersJob, type: :job do
  describe  do
    it { expect { QuarterlyReports::NotifyManagersJob.perform_async }.to enqueue_sidekiq_job }
  end
end
