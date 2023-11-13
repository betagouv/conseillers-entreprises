require 'rails_helper'
RSpec.describe Admin::SendFailedJobsJob do
  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end
end
