require 'rails_helper'
RSpec.describe UpdateAntenneCoverageJob do
  describe 'enqueue a job with an antenne' do
    let(:antenne) { create(:antenne) }

    it { expect { described_class.perform_async(antenne.id) }.to enqueue_sidekiq_job.with(antenne.id) }
  end
end
