# frozen_string_literal: true

require 'rails_helper'
describe CancelSolicitationWithEmail do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#cancel' do
    context 'with valid params' do
      let(:solicitation) { create :solicitation, status: 'in_progress' }
      let(:email_type) { :siret }

      before { described_class.new(solicitation, email_type).cancel }

      it do
        expect(solicitation.badges.size).to eq 1
        expect(solicitation.badges.first.title).to eq I18n.t(email_type, scope: 'solicitations.solicitation_actions.emails')
        expect(solicitation.status).to eq 'canceled'
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
      end
    end

    context 'with invalid email_type' do
      let(:solicitation) { create :solicitation, status: 'in_progress' }
      let(:email_type) { :tatayoyo }

      it do
        expect { described_class.new(solicitation, email_type).cancel }.to raise_error StandardError
      end
    end
  end
end
