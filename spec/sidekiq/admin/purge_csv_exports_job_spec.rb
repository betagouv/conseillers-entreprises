require 'rails_helper'
RSpec.describe Admin::PurgeCsvExportsJob, type: :job do
  describe  do
    it { expect { Admin::PurgeCsvExportsJob.perform_async }.to enqueue_sidekiq_job }
  end
end
