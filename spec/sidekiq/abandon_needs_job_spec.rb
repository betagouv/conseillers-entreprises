require 'rails_helper'
RSpec.describe AbandonNeedsJob, type: :job do
  describe  do
    it { expect { AbandonNeedsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
