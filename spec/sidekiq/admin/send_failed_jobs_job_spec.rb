require 'rails_helper'
RSpec.describe Admin::SendFailedJobsJob, type: :job do
  describe  do
    it { expect { Admin::SendFailedJobsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
