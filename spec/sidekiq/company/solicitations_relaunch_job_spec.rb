require 'rails_helper'
RSpec.describe Company::SolicitationsRelaunchJob, type: :job do

  describe do
    it 'expect to enqueue a job' do
      expect { described_class.perform_async }.to enqueue_sidekiq_job
    end
  end

  describe 'perform' do
    let!(:solicitation) { create :solicitation, email: 'alain@chabat.fr', status: :step_company, created_at: 1.day.ago }

    it 'send emails to solicitations not completed' do
      described_class.perform_sync
      expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
                                   "CompanyMailer",
                                   "solicitation_relaunch_company",
                                   "deliver_now",
                                   solicitation,
                                   true
                                 )
      expect(described_class).to enqueue_sidekiq_job
    end
  end
end
