require 'rails_helper'

# Characterization specs locking the current output of the matches two-rate
# graphs. Matches are bucketed by their status but grouped by the need's
# created_at month; the single-query refactor must preserve both.
describe 'Stats::Matches two-rate graphs', type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-02-28' } }

  before do
    travel_to(Time.zone.parse('2026-02-15 12:00'))
    rows = {
      done: '2026-01-10', quo: '2026-01-11', taking_care: '2026-01-12',
      done_no_help: '2026-02-05', done_not_reachable: '2026-02-06', not_for_me: '2026-02-07'
    }.map do |status, created_at|
      need = create(:diagnosis_completed).needs.first
      [need, need.matches.first, status, created_at]
    end
    rows.each do |need, match, status, created_at|
      match.update_columns(status: status)
      need.update_columns(created_at: created_at)
    end
  end

  def graph(klass)
    "Stats::Matches::#{klass}".constantize.new(params)
  end

  {
    'Done' => ['stats.done_status', [2, 3], [1, 0], '17%', 1],
    'DoneNoHelp' => ['stats.done_no_help_status', [3, 2], [0, 1], '17%', 1],
    'DoneNotReachable' => ['stats.not_reachable_status', [3, 2], [0, 1], '17%', 1],
    'NotForMe' => ['stats.not_for_me_status', [3, 2], [0, 1], '17%', 1],
    'TakingCare' => ['stats.taking_care_status', [2, 3], [1, 0], '17%', 1]
  }.each do |klass, (target_key, other_data, target_data, count, secondary)|
    it "#{klass} keeps its status split, rate and secondary count" do
      g = graph(klass)
      expect(g.series).to eq [
        { name: I18n.t('stats.other_status'), data: other_data },
        { name: I18n.t(target_key), data: target_data }
      ]
      expect(g.count).to eq count
      expect(g.secondary_count).to eq secondary
    end
  end

  it 'Positioning keeps non-quo as the positioning bucket' do
    g = graph('Positioning')
    expect(g.series).to eq [
      { name: I18n.t('stats.not_positioning'), data: [1, 0] },
      { name: I18n.t('stats.positioning'), data: [2, 3] }
    ]
    expect(g.count).to eq '83%'
    expect(g.secondary_count).to eq 5
  end

  it 'NotPositioning mirrors Positioning with quo as target' do
    g = graph('NotPositioning')
    expect(g.series).to eq [
      { name: I18n.t('stats.positioning'), data: [2, 3] },
      { name: I18n.t('stats.not_positioning'), data: [1, 0] }
    ]
    expect(g.count).to eq '17%'
    expect(g.secondary_count).to eq 1
  end

  it 'computes each graph in a bounded number of queries' do
    %w[Done DoneNoHelp DoneNotReachable NotForMe TakingCare Positioning NotPositioning].each do |klass|
      g = graph(klass)
      queries = QueryCounter.count { g.series; g.count; g.secondary_count }
      expect(queries).to be <= 3, "#{klass} issued #{queries} queries"
    end
  end
end
