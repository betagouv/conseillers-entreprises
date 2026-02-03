class Antenne
  module Monitoring
    extend ActiveSupport::Concern

    included do
      attributes :received_matches_count
      attributes :done_count, :done_rate
      attributes :not_for_me_count, :not_for_me_rate
      attributes :company_satisfactions_count
      attributes :contacted_by_expert_count, :useful_exchange_count, :satisfying_count, :satisfying_rate

      scope :often_not_for_me, -> do
        by_not_for_me(rate: 0.3.., activity: 50.., period: TimeDurationService::Quarters.new.call.first)
      end

      scope :by_not_for_me, -> (rate:, activity:, period:) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(received_matches_count: activity)
          .where(not_for_me_rate: rate)
      end

      scope :rarely_done, -> do
        by_done(rate: ..0.25, activity: 50.., period: TimeDurationService::Quarters.new.call.first)
      end

      scope :by_done, -> (rate:, activity:, period:) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(received_matches_count: activity)
          .where(done_rate: rate)
      end

      scope :includes_match_status_rates, -> (period:) do
        from(includes_match_status_counts(period: period), 'antennes')
          .select(<<~SQL.squish
            *,
            done_count::FLOAT / received_matches_count::FLOAT AS done_rate,
            not_for_me_count::FLOAT / received_matches_count::FLOAT as not_for_me_rate
          SQL
                 )
      end

      scope :includes_match_status_counts, -> (period:) do
        joins(:received_matches)
          .where(matches: { sent_at: period })
          .group(:id)
          .select(<<~SQL.squish
            antennes.*,
            COUNT(matches.id) AS received_matches_count,
            SUM(CASE WHEN matches.status IN ('done') THEN 1 ELSE 0 END) AS done_count,
            SUM(CASE WHEN matches.status IN ('not_for_me') THEN 1 ELSE 0 END) AS not_for_me_count
          SQL
                 )
      end

      scope :rarely_satisfying, ->  do
        by_satisfaction(rate: ..0.45, activity: 100.., period: TimeDurationService::Years.new.call.first)
      end

      scope :by_satisfaction, -> (rate:, activity:, period:) do
        from(includes_satisfying_rate(period: period), 'antennes')
          .where(company_satisfactions_count: activity)
          .where(satisfying_rate: rate)
      end

      scope :includes_satisfying_rate, -> (period:) do
        from(includes_satisfaction_counts(period: period), 'antennes')
          .select(<<~SQL.squish
            *,
            satisfying_count::FLOAT / company_satisfactions_count::FLOAT AS satisfying_rate
          SQL
                 )
      end

      scope :includes_satisfaction_counts, -> (period:) do
        joins(received_matches: { need: :company_satisfaction })
          .where(matches: { status: :done })
          .where(matches: { sent_at: period })
          .group(:id)
          .select(<<~SQL.squish
            antennes.*,
            COUNT(matches.id) AS received_matches_count,
            COUNT(company_satisfactions.id) AS company_satisfactions_count,
            COUNT(CASE company_satisfactions.contacted_by_expert WHEN TRUE THEN 1 ELSE NULL END) AS contacted_by_expert_count,
            COUNT(CASE company_satisfactions.useful_exchange WHEN TRUE THEN 1 ELSE NULL END) AS useful_exchange_count,
            COUNT(CASE company_satisfactions.contacted_by_expert AND company_satisfactions.useful_exchange WHEN TRUE THEN 1 ELSE NULL END) AS satisfying_count
          SQL
                 )
      end
    end
  end
end
