class Antenne
  module Monitoring
    extend ActiveSupport::Concern

    included do
      # attributes :received_matches_count
      # attributes :taking_care_count, :taking_care_rate
      # attributes :rejecting_count, :rejecting_rate
      # attributes :company_satisfactions_count
      # attributes :contacted_by_expert_count, :useful_exchange_count, :satisfying_count, :satisfying_rate

      scope :often_rejecting, -> do
        by_rejection(rate: 0.3.., activity: 50.., period: TimeDurationService::Quarters.new.call.first)
      end

      scope :by_rejection, -> (rate:, activity:, period:) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(received_matches_count: activity)
          .where(rejecting_rate: rate)
      end

      scope :rarely_taking_care, -> do
        by_taken_care_of(rate: ..0.25, activity: 50.., period: TimeDurationService::Quarters.new.call.first)
      end

      scope :by_taken_care_of, -> (rate:, activity:, period:) do
        from(includes_match_status_rates(period: period), 'antennes')
          .where(received_matches_count: activity)
          .where(taking_care_rate: rate)
      end

      scope :includes_match_status_rates, -> (period:) do
        from(includes_match_status_counts(period: period), 'antennes')
          .select(<<~SQL.squish
            *,
            taking_care_count::FLOAT / received_matches_count::FLOAT AS taking_care_rate,
            rejecting_count::FLOAT / received_matches_count::FLOAT as rejecting_rate
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
            SUM(CASE WHEN matches.status IN ('taking_care', 'done', 'done_no_help', 'done_not_reachable') THEN 1 ELSE 0 END) AS taking_care_count,
            SUM(CASE WHEN matches.status IN ('not_for_me') THEN 1 ELSE 0 END) AS rejecting_count
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
