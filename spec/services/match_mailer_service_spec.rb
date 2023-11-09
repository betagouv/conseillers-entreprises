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
        expect(Sidekiq::Job.jobs.count).to eq 1
        expect(SendStatusNotificationJob).to have_enqueued_sidekiq_job(a_match.id, 'quo')
      end
    end

    context 'change back to the initial value' do
      before do
        notify_change(:not_for_me)
        notify_change(:quo)
      end

      # ici on veut un nouveau job qui n'envoie pas d'email ou pas de job du tout
      it { expect(SendStatusNotificationJob).not_to have_enqueued_sidekiq_job(a_match.id, 'quo') }
    end

    context 'match taking_care and match not reachable' do
      before do
        notify_change(:taking_care)
        notify_change(:done_not_reachable)
      end

      it do
        expect(enqueued_jobs.count).to eq 1
        previous_status = Delayed::Job.last.payload_object.args.last.to_sym
        expect(previous_status).to eq :quo
      end
    end
  end
end
