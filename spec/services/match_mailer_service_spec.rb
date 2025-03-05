# frozen_string_literal: true

require 'rails_helper'
describe MatchMailerService do
  Sidekiq::Testing.disable!

  let!(:national_referent) { create :user, :national_referent }

  before do
    ENV['APPLICATION_EMAIL'] = 'contact@mailrandom.fr'
  end

  describe '#deduplicated_notify_status' do
    def notify_change(new_status)
      previous_status = a_match.status
      a_match.status = new_status
      described_class.new(a_match).deduplicated_notify_status(previous_status)
    end

    let!(:a_match) { create :match, status: :quo }

    context 'subsequent changes on the same match' do
      before do
        Sidekiq::ScheduledSet.new.clear
        notify_change(:taking_care)
        notify_change(:done)
      end

      it do
        # Pour supprimer les jobs lancés à la création des items
        scheduled = Sidekiq::ScheduledSet.new
        expect(scheduled.size).to eq 1
        expect(scheduled.first.args).to eq([a_match.id, 'quo'])
        expect(a_match.status).to eq 'done'
      end
    end

    context 'change back to the initial value' do
      before do
        Sidekiq::ScheduledSet.new.clear
        notify_change(:not_for_me)
        notify_change(:quo)
      end

      it do
        scheduled = Sidekiq::ScheduledSet.new
        # Pas de job de lancé comme le statut ne change pas
        expect(scheduled.size).to eq 0
        expect(a_match.status).to eq 'quo'
      end
    end

    context 'match taking_care and match not reachable' do
      before do
        Sidekiq::ScheduledSet.new.clear
        notify_change(:taking_care)
        notify_change(:done_not_reachable)
      end

      it do
        scheduled = Sidekiq::ScheduledSet.new
        expect(scheduled.size).to eq 1
        expect(scheduled.first.args).to eq([a_match.id, 'quo'])
        expect(a_match.status).to eq 'done_not_reachable'
      end
    end
  end
end
