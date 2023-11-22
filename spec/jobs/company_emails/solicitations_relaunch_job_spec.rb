require 'rails_helper'
RSpec.describe CompanyEmails::SolicitationsRelaunchJob do

  describe 'enqueue a job' do
    it { assert_enqueued_jobs(1) { described_class.perform_later } }
  end

  describe 'perform' do
    let!(:solicitation) { create :solicitation, email: 'alain@chabat.fr', status: :step_company, created_at: 25.hours.ago }

    it 'send emails to solicitations not completed' do
      described_class.perform_now
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["CompanyMailer", "solicitation_relaunch_company", "deliver_now", { args: [solicitation] }])
    end
  end
end
