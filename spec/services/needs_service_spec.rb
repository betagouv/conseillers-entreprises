# frozen_string_literal: true

require 'rails_helper'
describe NeedsService do
  describe 'archive_old_needs' do
    # besoin de moins de 6 mois quo done_no_help done_not_reachable   ko
    # besoin de plus de 6 mois quo done_no_help done_not_reachable    ok
    # besoin de moins de 6 mois done                                  ko
    # besoin de plus de 6 mois done                                   ko
    let!(:need1) { create :need, matches: [match1] }
    let(:match1) { create :match, status: :quo }
    let!(:need2) { create :need, created_at: 6.months.ago, matches: [match2] }
    let(:match2) { create :match, status: :quo, created_at: 6.months.ago }
    let!(:need3) { create :need, matches: [match3] }
    let(:match3) { create :match, status: :done }
    let!(:need4) { create :need, created_at: 6.months.ago, matches: [match4] }
    let(:match4) { create :match, status: :done, created_at: 6.months.ago }

    before { described_class.archive_old_needs }

    it 'archive only old quo, done_no_help, done_not_reachable need' do
      expect(need1.reload.archived_at).to be_nil
      expect(need2.reload.archived_at).not_to be_nil
      expect(need3.reload.archived_at).to be_nil
      expect(need4.reload.archived_at).to be_nil
    end
  end

  describe 'abandon_needs' do
    context 'without last chance email' do
      # Besoin quo done_no_help done_not_reachable de moins de 45 jours   ko
      # Besoin quo done_no_help done_not_reachable de moins de 45 jours   ko
      # Besoin quo done_no_help done_not_reachable de plus de 45 jours    ok
      # Besoin done de moins de 45 jours                                  ko
      # Besoin done de plus de 45 jours                                   ko
      # Besoin done_no_help de moins de 45 jours                          ko
      # Besoin done_not_reachable de moins de 45 jours                    ko

      let!(:need1) { create :need, matches: [match1] }
      let(:match1) { create :match, status: :quo }
      let!(:need2) { create :need, matches: [match2], created_at: 45.days.ago }
      let(:match2) { create :match, status: :quo, created_at: 45.days.ago }
      let!(:need3) { create :need, matches: [match3] }
      let(:match3) { create :match, status: :done }
      let!(:need4) { create :need, matches: [match4], created_at: 45.days.ago }
      let(:match4) { create :match, status: :done, created_at: 45.days.ago }
      let!(:need5) { create :need, matches: [match5] }
      let(:match5) { create :match, status: :done_no_help }
      let!(:need6) { create :need, matches: [match6] }
      let(:match6) { create :match, status: :done_not_reachable }

      before { described_class.abandon_needs }

      it 'abandon only old needs without help and send' do
        expect(need1.reload.abandoned_email_sent).to be false
        expect(need2.reload.abandoned_email_sent).to be true
        expect(need3.reload.abandoned_email_sent).to be false
        expect(need4.reload.abandoned_email_sent).to be false
        expect(need5.reload.abandoned_email_sent).to be false
        expect(need6.reload.abandoned_email_sent).to be false
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end
    end

    context 'with last chance email' do
      # Besoin quo de moins de 10 jours après le mail  ko
      # Besoin quo de plus de 10 jours après le mail   ok
      # Besoin done de moins de 40 jours de moins de 10 jours après le mail            ko
      # Besoin done de plus de 40 jours de plus de 10 jours après le mail              ko

      let!(:need1) { create :need, matches: [match1], reminders_actions: [reminders_actions1] }
      let(:reminders_actions1) { create :reminders_action, category: 'last_chance' }
      let(:match1) { create :match, status: :quo }
      let!(:need2) { create :need, matches: [match2], created_at: 40.days.ago, reminders_actions: [reminders_actions2] }
      let(:reminders_actions2) { create :reminders_action, category: 'last_chance', created_at: 11.days.ago }
      let(:match2) { create :match, status: :quo, created_at: 40.days.ago }
      let!(:need3) { create :need, matches: [match3], reminders_actions: [reminders_actions3] }
      let(:reminders_actions3) { create :reminders_action, category: 'last_chance' }
      let(:match3) { create :match, status: :done }
      let!(:need4) { create :need, matches: [match4], created_at: 40.days.ago, reminders_actions: [reminders_actions4] }
      let(:reminders_actions4) { create :reminders_action, category: 'last_chance', created_at: 11.days.ago }
      let(:match4) { create :match, status: :done, created_at: 40.days.ago }

      before { described_class.abandon_needs }

      it 'abandon only old needs without help and send' do
        expect(need1.reload.abandoned_email_sent).to be false
        expect(need2.reload.abandoned_email_sent).to be true
        expect(need3.reload.abandoned_email_sent).to be false
        expect(need4.reload.abandoned_email_sent).to be false
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end
    end
  end
end
