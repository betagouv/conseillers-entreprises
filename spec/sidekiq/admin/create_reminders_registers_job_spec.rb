require 'rails_helper'
RSpec.describe Admin::CreateRemindersRegistersJob, type: :job do
  describe  do
    it { expect { Admin::CreateRemindersRegistersJob.perform_async }.to enqueue_sidekiq_job }
  end
end
