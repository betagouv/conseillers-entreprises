require 'rails_helper'
RSpec.describe Company::NotYetTakenCareJob, type: :job do
  describe  do
    it { expect { Company::NotYetTakenCareJob.perform_async }.to enqueue_sidekiq_job }
  end
end
