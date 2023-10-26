require 'rails_helper'
RSpec.describe Company::SendIntelligentRetentionEmailsJob, type: :job do
  describe  do
    it { expect { Company::SendIntelligentRetentionEmailsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
