require 'rails_helper'
RSpec.describe SendStatusNotificationJob, type: :job do
  describe  do
    let(:a_match) { create(:match) }
    it { expect { SendStatusNotificationJob.perform_async(a_match.id, 'quo') }.to enqueue_sidekiq_job.with(a_match.id, 'quo') }
  end
end
