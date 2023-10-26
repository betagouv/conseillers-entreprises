require 'rails_helper'
RSpec.describe PurgeCsvExportsJob, type: :job do
  describe  do
    it { expect { PurgeCsvExportsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
