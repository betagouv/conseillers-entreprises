require 'rails_helper'

# Characterization specs locking the current output of the needs two-rate graphs
# (series, count, secondary_count) so the single-query refactor is proven
# behaviour-preserving. One deterministic seed spanning two months feeds every
# graph; empty buckets (e.g. requalification's "not requalified") must survive.
describe 'Stats::Needs two-rate graphs', type: :model do
  let(:params) { { start_date: '2026-01-01', end_date: '2026-02-28' } }

  before do
    travel_to(Time.zone.parse('2026-02-15 12:00'))
    needs = {
      done: '2026-01-10', quo: '2026-01-11', taking_care: '2026-01-12',
      done_no_help: '2026-02-05', done_not_reachable: '2026-02-06', not_for_me: '2026-02-07'
    }.map do |status, created_at|
      [create(:diagnosis_completed).needs.first, status, created_at]
    end
    create(:reminders_action, need: needs.first.first, category: :abandon)
    # Set statuses LAST so no callback/touch resets them.
    needs.each { |need, status, created_at| need.update_columns(status: status, created_at: created_at) }
  end

  def graph(klass)
    "Stats::Needs::#{klass}".constantize.new(params)
  end

  {
    'Done' => ['stats.status_done', [2, 3], [1, 0], '17%', 1],
    'Quo' => ['stats.status_quo', [2, 3], [1, 0], '17%', 1],
    'TakingCare' => ['stats.status_taking_care', [2, 3], [1, 0], '17%', 1],
    'DoneNoHelp' => ['stats.status_done_no_help', [3, 2], [0, 1], '17%', 1],
    'DoneNotReachable' => ['stats.status_done_not_reachable', [3, 2], [0, 1], '17%', 1],
    'NotForMe' => ['stats.status_not_for_me', [3, 2], [0, 1], '17%', 1]
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

  it 'Positioning keeps quo vs non-quo split' do
    g = graph('Positioning')
    expect(g.series).to eq [
      { name: I18n.t('stats.not_positioning'), data: [1, 0] },
      { name: I18n.t('stats.positioning'), data: [2, 3] }
    ]
    expect(g.count).to eq '83%'
    expect(g.secondary_count).to eq 5
  end

  it 'ExchangeWithExpert splits by exchange statuses' do
    g = graph('ExchangeWithExpert')
    expect(g.series).to eq [
      { name: I18n.t('stats.series.needs_exchange_with_expert.without_exchange'), data: [2, 2] },
      { name: I18n.t('stats.series.needs_exchange_with_expert.with_exchange'), data: [1, 1] }
    ]
    expect(g.count).to eq '33%'
    expect(g.secondary_count).to eq 2
  end

  it 'Requalification keeps the empty not-requalified bucket' do
    g = graph('Requalification')
    expect(g.series).to eq [
      { name: I18n.t('stats.series.needs_requalification.not_requalified'), data: [0, 0] },
      { name: I18n.t('stats.series.needs_requalification.requalified'), data: [3, 3] }
    ]
    expect(g.count).to eq '100%'
    expect(g.secondary_count).to eq 6
  end

  it 'AbandonedTotalCount counts abandoned needs, secondary is the total' do
    g = graph('AbandonedTotalCount')
    expect(g.series).to eq [
      { name: I18n.t('stats.series.needs_abandoned_total_count.other_needs'), data: [2, 3] },
      { name: I18n.t('stats.series.needs_abandoned_total_count.abandoned_needs'), data: [1, 0] }
    ]
    expect(g.count).to eq '17%'
    expect(g.secondary_count).to eq 6
  end

  it 'Transmitted is a single distinct-count series' do
    g = graph('Transmitted')
    expect(g.series).to eq [
      { name: I18n.t('stats.series.transmitted_needs.title'), data: [3, 3] }
    ]
    expect(g.count).to eq 6
    expect(g.secondary_count).to be_nil
  end

  it 'computes each graph in a bounded number of queries' do
    %w[
      Done Quo TakingCare DoneNoHelp DoneNotReachable NotForMe Positioning
      ExchangeWithExpert Requalification AbandonedTotalCount Transmitted
    ].each do |klass|
      g = graph(klass)
      queries = QueryCounter.count { g.series; g.count; g.secondary_count }
      expect(queries).to be <= 3, "#{klass} issued #{queries} queries"
    end
  end
end
