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
end
