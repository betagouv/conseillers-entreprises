require 'rails_helper'

# Characterization specs locking the current output of the solicitations graphs
# before the single-query refactor. Completed and Diagnoses are grouped by the
# solicitation's completed_at; TransmittedLessThan72h is grouped by created_at
# and deliberately counts the diagnosis->needs join fan-out.
describe 'Stats::Solicitations graphs', type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-02-28' } }

  before { travel_to(Time.zone.parse('2026-02-15 12:00')) }

  describe Stats::Solicitations::Completed do
    before do
      create(:solicitation, status: :in_progress, completed_at: '2026-01-10')
      create(:solicitation, status: :processed, completed_at: '2026-01-20')
      create(:solicitation, status: :canceled, completed_at: '2026-02-05')
    end

    it 'counts completed solicitations per completion month' do
      g = described_class.new(params)
      expect(g.series).to eq [
        { name: I18n.t('stats.series.solicitations_completed.series'), data: [2, 1] }
      ]
      expect(g.count).to eq 3
      expect(g.secondary_count).to be_nil
      expect(QueryCounter.count { fresh = described_class.new(params); fresh.series; fresh.count }).to be <= 2
    end
  end

  describe Stats::Solicitations::Diagnoses do
    before do
      sol_a = create(:solicitation, status: :in_progress, completed_at: '2026-01-10')
      create(:diagnosis_completed, solicitation: sol_a)
      sol_b = create(:solicitation, status: :in_progress, completed_at: '2026-01-11')
      create(:diagnosis, solicitation: sol_b) # step 1 => in progress
      create(:solicitation, status: :in_progress, completed_at: '2026-02-05') # no diagnosis
    end

    it 'splits solicitations by completed-diagnosis presence' do
      g = described_class.new(params)
      expect(g.series).to eq [
        { name: I18n.t('stats.without_diagnosis'), data: [1, 1] },
        { name: I18n.t('stats.with_diagnosis'), data: [1, 0] }
      ]
      expect(g.count).to eq '33%'
      expect(g.secondary_count).to eq 1
      expect(QueryCounter.count { fresh = described_class.new(params); fresh.series; fresh.count; fresh.secondary_count }).to be <= 3
    end
  end

  describe Stats::Solicitations::TransmittedLessThan72h do
    before do
      [['2026-01-10', '2026-01-11'], ['2026-01-12', '2026-01-20'], ['2026-02-05', nil]].each do |created_at, completed_at|
        diagnosis = create(:diagnosis_completed)
        diagnosis.solicitation.update_columns(status: Solicitation.statuses[:processed], created_at: created_at)
        diagnosis.update_columns(completed_at: completed_at)
      end
    end

    it 'splits processed solicitations by the 72h transmission window' do
      g = described_class.new(params)
      expect(g.series).to eq [
        { name: I18n.t('stats.more_than_72h'), data: [1, 0] },
        { name: I18n.t('stats.less_than_72h'), data: [1, 0] }
      ]
      expect(g.count).to eq '50%'
      expect(g.secondary_count).to be_nil
      expect(QueryCounter.count { fresh = described_class.new(params); fresh.series; fresh.count }).to be <= 2
    end
  end
end
