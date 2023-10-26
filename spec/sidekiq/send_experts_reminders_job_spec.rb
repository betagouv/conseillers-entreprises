require 'rails_helper'
RSpec.describe SendExpertsRemindersJob, type: :job do
  describe  do
    it { expect { SendExpertsRemindersJob.perform_async }.to enqueue_sidekiq_job }
  end
end
