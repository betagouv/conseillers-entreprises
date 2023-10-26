require 'rails_helper'
RSpec.describe ApiKeysRevokeJob, type: :job do
  describe  do
    it { expect { ApiKeysRevokeJob.perform_async }.to enqueue_sidekiq_job }
  end
end
