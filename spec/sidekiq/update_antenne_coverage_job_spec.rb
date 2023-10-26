require 'rails_helper'
RSpec.describe UpdateAntenneCoverageJob, type: :job do
  describe  do
    let(:antenne) { create(:antenne) }
    it { expect { UpdateAntenneCoverageJob.perform_async(antenne.id) }.to enqueue_sidekiq_job.with(antenne.id) }
  end
end
