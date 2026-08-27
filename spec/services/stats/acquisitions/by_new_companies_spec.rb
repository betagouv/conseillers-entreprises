require 'rails_helper'

describe Stats::Acquisitions::ByNewCompanies, type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-01-31' } }
  let(:graph) { described_class.new(params) }

  def done_need(solicitation:, facility:, created_at:)
    diagnosis = create(:diagnosis_completed, solicitation: solicitation, facility: facility)
    need = diagnosis.needs.first
    need.update_columns(created_at: created_at, status: Need.statuses[:done])
    need
  end

  before do
    travel_to(Time.zone.parse('2026-01-15 12:00'))
    facility = create(:facility)
    first_solicitation = create(:solicitation)   # min id for the facility => "new"
    later_solicitation = create(:solicitation)   # not the first => "known"
    done_need(solicitation: first_solicitation, facility: facility, created_at: '2026-01-10')
    done_need(solicitation: later_solicitation, facility: facility, created_at: '2026-01-12')
  end

  it 'splits needs between known and new companies (order preserved)' do
    expect(graph.series).to eq [
      { name: I18n.t('stats.from_known_companies'), data: [1] },
      { name: I18n.t('stats.from_new_companies'), data: [1] }
    ]
  end

  it 'derives the new-companies rate and secondary count from the series' do
    expect(graph.count).to eq '50%'
    expect(graph.secondary_count).to eq 1
  end

  it 'computes everything in a bounded number of queries' do
    expect(QueryCounter.count { graph.series; graph.count; graph.secondary_count }).to be <= 2
  end
end
