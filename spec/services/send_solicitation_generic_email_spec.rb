require 'rails_helper'
describe SendSolicitationGenericEmail do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#cancel' do
    context 'with valid params' do
      let(:solicitation) { create :solicitation, status: 'in_progress' }
      let(:email_type) { 'siret' }

      before do
        create(:solicitation_mail_template, email_type: 'siret', title: 'Erreur SIRET')
        described_class.new(solicitation, email_type).send_email
      end

      it do
        expect(solicitation.badges.size).to eq 1
        expect(solicitation.badges.first.title).to eq 'Erreur SIRET'
        expect(solicitation.status).to eq 'canceled'
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
        expect(enqueued_jobs.count).to eq 1
      end
    end

    context 'with bad_quality built-in type' do
      let(:solicitation) { create :solicitation, status: 'in_progress' }
      let(:email_type) { 'bad_quality' }

      before { described_class.new(solicitation, email_type).send_email }

      it 'sends the bad_quality email without requiring a template' do
        expect(solicitation.badges.size).to eq 1
        expect(solicitation.status).to eq 'canceled'
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
        expect(enqueued_jobs.count).to eq 1
      end
    end

    context 'with invalid email_type' do
      let(:solicitation) { create :solicitation, status: 'in_progress' }
      let(:email_type) { 'tatayoyo' }

      it do
        expect { described_class.new(solicitation, email_type).send_email }.to raise_error StandardError
      end
    end
  end
end
