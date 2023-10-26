require 'rails_helper'
RSpec.describe Company::SendSatisfactionEmailsJob, type: :job do
  describe  do
    it { expect { Company::SendSatisfactionEmailsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
