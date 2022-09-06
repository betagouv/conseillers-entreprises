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
end
