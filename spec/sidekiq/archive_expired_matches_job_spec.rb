require 'rails_helper'
RSpec.describe ArchiveExpiredMatchesJob, type: :job do
  describe  do
    it { expect { ArchiveExpiredMatchesJob.perform_async }.to enqueue_sidekiq_job }
  end
end
