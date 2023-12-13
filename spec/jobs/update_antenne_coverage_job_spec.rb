require 'rails_helper'
RSpec.describe UpdateAntenneCoverageJob do
  describe 'enqueue a job with an antenne' do
    let(:antenne) { create(:antenne) }

    xit do
      described_class.perform_async(antenne.id)
      expect(Sidekiq::Job.jobs.count).to eq(1)
      expect(Sidekiq::Job.jobs.first['args']).to eq([antenne.id])
    end
  end
end
