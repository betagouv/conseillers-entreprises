require 'rails_helper'

# Characterization specs for the response-time graphs. Needs are bucketed by the
# need's created_at and counted at the need level (EXISTS + distinct); matches
# are bucketed by the match's created_at. Both split on the day gap between
# sent_at and taken_care_of_at. The single-query refactor must preserve all of it.
describe 'Response-time graphs', type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-02-28' } }

  before do
    travel_to(Time.zone.parse('2026-02-15 12:00'))
    [
      ['done', 'done', '2026-01-10 09:00', '2026-01-11 09:00', '2026-01-10'],          # gap 1 day
      ['done', 'done_no_help', '2026-01-11 09:00', '2026-01-15 09:00', '2026-01-11'],  # gap 4 days
      ['done', 'done', '2026-02-05 09:00', '2026-02-20 09:00', '2026-02-05']           # gap 15 days
    ].each do |need_status, match_status, sent_at, taken_care_of_at, created_at|
      need = create(:diagnosis_completed).needs.first
      match = need.matches.first
      match.update_columns(status: match_status, sent_at: sent_at, taken_care_of_at: taken_care_of_at)
      need.update_columns(status: need_status, created_at: created_at)
    end
  end

  def after_before(scope, before_data, after_data)
    [
      { name: I18n.t("stats.#{scope}.taken_care_after"), data: after_data },
      { name: I18n.t("stats.#{scope}.taken_care_before"), data: before_data }
    ]
  end

  it 'Needs::TakenCareInThreeDays buckets needs by their own month' do
    g = Stats::Needs::TakenCareInThreeDays.new(params)
    expect(g.series).to eq after_before('taken_care_in_three_days', [1, 0], [1, 1])
    expect(g.count).to eq '33%'
    expect(g.secondary_count).to be_nil
  end

  it 'Needs::TakenCareInFiveDays widens the gap' do
    g = Stats::Needs::TakenCareInFiveDays.new(params)
    expect(g.series).to eq after_before('taken_care_in_five_days', [2, 0], [0, 1])
    expect(g.count).to eq '67%'
    expect(g.secondary_count).to be_nil
  end

  it 'Needs::HelpedInFiveDays restricts to done needs' do
    g = Stats::Needs::HelpedInFiveDays.new(params)
    expect(g.series).to eq after_before('taken_care_in_five_days', [2, 0], [0, 1])
    expect(g.count).to eq '67%'
    expect(g.secondary_count).to be_nil
  end

  it 'Matches::TakenCareInThreeDays buckets matches by their own month' do
    g = Stats::Matches::TakenCareInThreeDays.new(params)
    expect(g.series).to eq after_before('taken_care_in_three_days', [0, 1], [0, 2])
    expect(g.count).to eq '33%'
    expect(g.secondary_count).to eq 1
  end

  it 'Matches::TakenCareInFiveDays widens the gap' do
    g = Stats::Matches::TakenCareInFiveDays.new(params)
    expect(g.series).to eq after_before('taken_care_in_five_days', [0, 2], [0, 1])
    expect(g.count).to eq '67%'
    expect(g.secondary_count).to eq 2
  end

  it 'computes each graph in a bounded number of queries' do
    [
      Stats::Needs::TakenCareInThreeDays, Stats::Needs::TakenCareInFiveDays, Stats::Needs::HelpedInFiveDays,
      Stats::Matches::TakenCareInThreeDays, Stats::Matches::TakenCareInFiveDays
    ].each do |klass|
      g = klass.new(params)
      queries = QueryCounter.count { g.series; g.count; g.secondary_count }
      expect(queries).to be <= 3, "#{klass} issued #{queries} queries"
    end
  end
end
