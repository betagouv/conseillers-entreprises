require 'rails_helper'

describe 'Stats::Acquisitions overall distribution', type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-02-28' } }
  let(:line) { Stats::Acquisitions::OverallDistributionNeedsTransmitted.new(params) }
  let(:column) { Stats::Acquisitions::OverallDistributionNeedsTransmittedColumn.new(params) }

  def create_need(created_at:, integration: :intern, form_info: {})
    landing = create(:landing, integration: integration)
    solicitation = create(:solicitation, landing: landing, form_info: form_info)
    diagnosis = create(:diagnosis_completed, solicitation: solicitation)
    need = diagnosis.needs.first
    need.update_columns(created_at: created_at)
    need
  end

  before do
    travel_to(Time.zone.parse('2026-02-15 12:00'))
    # January
    create_need(created_at: '2026-01-10', form_info: { mtm_campaign: 'entreprendre' }) # A
    create_need(created_at: '2026-01-12', integration: :iframe) # B
    # February
    create_need(created_at: '2026-02-05', integration: :iframe, form_info: { mtm_campaign: 'entreprendre' }) # C overlap
    create_need(created_at: '2026-02-07', form_info: { mtm_campaign: 'googleads' })             # D
    create_need(created_at: '2026-02-09')                                                       # E plain / others
  end

  it 'buckets the line-chart series by acquisition source over the two months' do
    expect(line.all_months).to eq [Date.new(2026, 1, 1), Date.new(2026, 2, 1)]
    expect(line.series).to eq [
      { name: 'Entreprendre', data: [1, 1] },
      { name: 'Google Ads', data: [0, 1] },
      { name: 'Iframes', data: [1, 1] },
      { name: 'Redirections', data: [0, 0] },
      { name: 'API', data: [0, 0] }
    ]
  end

  it 'keeps the overlap semantics: from_others computed by subtraction, others first' do
    # need C matches both Entreprendre and Iframes, so from_others (a subtraction) stays 0 despite plain need E
    expect(column.series).to eq [
      { name: 'Autres provenances', data: [0, 0] },
      { name: 'Entreprendre', data: [1, 1] },
      { name: 'Google Ads', data: [0, 1] },
      { name: 'Iframes', data: [1, 1] },
      { name: 'Redirections', data: [0, 0] },
      { name: 'API', data: [0, 0] }
    ]
  end

  it 'computes each variant with a bounded number of queries' do
    expect(QueryCounter.count { line.series }).to be <= 2
    expect(QueryCounter.count { column.series }).to be <= 2
  end
end
