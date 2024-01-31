# frozen_string_literal: true

require 'rails_helper'
describe NeedsService do
  describe 'archive_expired_matches' do
    # match de moins de 6 mois quo          ko
    # match de plus de 6 mois quo           ok
    # match de plus de 6 mois not_for_me    ko
    # matche de plus de 6 mois taking_care  ko
    let!(:match1) { create :match, status: :quo }
    let!(:match2) { create :match, status: :quo, sent_at: 6.months.ago }
    let!(:match3) { create :match, status: :not_for_me, sent_at: 6.months.ago }
    let!(:match4) { create :match, status: :taking_care, sent_at: 6.months.ago }
    let!(:match5) { create :match, status: :done, sent_at: 6.months.ago }

    before { described_class.archive_expired_matches }

    it 'archive only old quo, done_no_help, done_not_reachable need' do
      expect(match1.reload.archived_at).to be_nil
      expect(match2.reload.archived_at).not_to be_nil
      expect(match3.reload.archived_at).to be_nil
      expect(match4.reload.archived_at).to be_nil
      expect(match5.reload.archived_at).to be_nil
    end
  end

  describe 'abandon_needs' do
    context 'without last chance email' do
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
        expect(need1.reload.is_abandoned?).to be false
        expect(need2.reload.is_abandoned?).to be true
        expect(need3.reload.is_abandoned?).to be false
        expect(need4.reload.is_abandoned?).to be false
        expect(need5.reload.is_abandoned?).to be false
        expect(need6.reload.is_abandoned?).to be false
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob)
        expect(enqueued_jobs.count).to eq 1
      end
    end
  end
end
