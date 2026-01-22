class Antenne
  module Monitoring
    extend ActiveSupport::Concern

    included do
      scope :often_rejecting, -> (rate: 0.3.., period: TimeDurationService::Quarters.new.call.first) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(rejecting_rate: rate)
      end

      scope :rarely_helping, -> (rate: ..0.25, period: TimeDurationService::Quarters.new.call.first) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(helping_rate: rate)
      end

      scope :includes_match_status_rates, -> (period: TimeDurationService::Quarters.new.call.first) do
        from(includes_match_status_counts(period: period), 'antennes')
          .select(<<~SQL.squish
            *,
            helping_count::FLOAT / received_matches_count::FLOAT AS helping_rate,
            rejecting_count::FLOAT / received_matches_count::FLOAT as rejecting_rate
          SQL
                 )
      end

      scope :includes_match_status_counts, -> (period: TimeDurationService::Quarters.new.call.first) do
        joins(:received_matches)
          .where(matches: { sent_at: period })
          .group(:id)
          .select(<<~SQL.squish
            antennes.*,
            COUNT(matches.id) AS received_matches_count,
            SUM(CASE WHEN matches.status IN ('taking_care', 'done', 'done_no_help', 'done_not_reachable') THEN 1 ELSE 0 END) AS helping_count,
            SUM(CASE WHEN matches.status IN ('not_for_me') THEN 1 ELSE 0 END) AS rejecting_count
          SQL
                 )
      end

      scope :rarely_satisfying, -> (rate: ..0.45, period: TimeDurationService::Years.new.call.first) do
        from(includes_satisfying_rate(period: period), 'antennes')
          .where(satisfying_rate: rate)
      end

      scope :includes_satisfying_rate, -> (period:) do
        from(includes_satisfaction_counts(period: period), 'antennes')
          .where(company_satisfactions_count: 100..)
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
