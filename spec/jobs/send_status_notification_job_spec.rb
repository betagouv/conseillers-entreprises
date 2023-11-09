require 'rails_helper'
RSpec.describe SendStatusNotificationJob, type: :job do
  describe 'enqueue a job with a match' do
    let(:a_match) { create(:match) }

    it { expect { described_class.perform_async(a_match.id, 'quo') }.to enqueue_sidekiq_job.with(a_match.id, 'quo') }
  end
end
