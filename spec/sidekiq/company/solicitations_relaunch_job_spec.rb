require 'rails_helper'
RSpec.describe Company::SolicitationsRelaunchJob, type: :job do
  describe  do
    it { expect { Company::SolicitationsRelaunchJob.perform_async }.to enqueue_sidekiq_job }
  end
end
