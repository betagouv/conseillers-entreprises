# frozen_string_literal: true

require 'rails_helper'
describe MatchMailerService do
  before { ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr' }

  describe '#deduplicated_notify_status' do
    def notify_change(new_status)
      previous_status = a_match.status
      a_match.status = new_status
      described_class.deduplicated_notify_status(a_match, previous_status)
    end

    let(:a_match) { create :match, status: :quo }

    context 'subsequent changes on the same match' do
      before do
        notify_change(:taking_care)
        notify_change(:done)
      end

      it do
        expect(Delayed::Job.count).to eq 1
        previous_status = Delayed::Job.last.payload_object.args.last.to_sym
        expect(previous_status).to eq :quo
      end
    end

    context 'change back to the initial value' do
      before do
        notify_change(:not_for_me)
        notify_change(:quo)
      end

      it do
        expect(Delayed::Job.count).to eq 0
      end
    end
  end

  describe '#notify_status' do
    before do
      mailer_double = double().as_null_object
      allow(UserMailer).to receive(:notify_match_status) { mailer_double }
      allow(CompanyMailer).to receive(:notify_taking_care) { mailer_double }

      described_class.notify_status(a_match, previous_status)
    end

    let(:a_match) { create :match, status: new_status }

    context 'taken care of now' do
      let(:previous_status) { 'quo' }
      let(:new_status) { 'taking_care' }

      it do
        expect(UserMailer).to have_received(:notify_match_status)
        expect(CompanyMailer).to have_received(:notify_taking_care)
      end
    end

    context 'already taken care of' do
      let(:previous_status) { 'done' }
      let(:new_status) { 'taking_care' }

      it do
        expect(UserMailer).to have_received(:notify_match_status)
        expect(CompanyMailer).not_to have_received(:notify_taking_care)
      end
    end

    context 'not taken care of' do
      let(:previous_status) { 'quo' }
      let(:new_status) { 'not_for_me' }

      it do
        expect(UserMailer).to have_received(:notify_match_status)
        expect(CompanyMailer).not_to have_received(:notify_taking_care)
      end
    end
  end
end
