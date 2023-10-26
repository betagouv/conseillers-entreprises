require 'rails_helper'
RSpec.describe Company::SendRetentionEmailsJob, type: :job do
  describe  do
    it { expect { Company::SendRetentionEmailsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
