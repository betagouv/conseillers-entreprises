class Antenne
  module Monitoring
    extend ActiveSupport::Concern

    included do
      ## High-level monitoring scopes
      # These three scopes rely on the implementation below to filter on the match status of satisfaction rates
      scope :often_not_for_me, -> do
        from(includes_match_status_rates(period: TimeDurationService::Quarters.new.call.first), self.table_name)
          .where(received_matches_count: 50..)
          .where(not_for_me_rate: 0.3..)
      end

      scope :rarely_done, -> do
        from(includes_match_status_rates(period: TimeDurationService::Quarters.new.call.first), self.table_name)
          .where(received_matches_count: 50..)
          .where(done_rate: ..0.25)
      end

      scope :rarely_satisfying, -> do
        from(includes_satisfying_rate(period: TimeDurationService::Years.new.call.first), self.table_name)
          .where(company_satisfactions_count: 100..)
          .where(satisfying_rate: ..0.45)
      end

      ## Low-level monitoring scopes
      # These scopes join / group by / count the received matches and compute the results as additional columns.
      # /!\ The second parameter of the #from calls is essential for the calling scope to properly work.

      # Compute match status rates
      # The returned collection has these additional new attributes:
      attribute :done_rate, :float
      attribute :not_for_me_rate, :float
      scope :includes_match_status_rates, -> (period:) do
        from(includes_match_status_counts(period: period), self.table_name)
          .select(<<~SQL.squish
            *,
            done_count::FLOAT / received_matches_count::FLOAT AS done_rate,
            not_for_me_count::FLOAT / received_matches_count::FLOAT as not_for_me_rate
          SQL
                 )
      end

      # Compute match status counts
      # The returned collection has these additional new attributes:
      attribute :received_matches_count, :integer
      attribute :done_count, :integer
      attribute :not_for_me_count, :integer
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

      # Compute company satisfaction rate
      # The returned collection has these additional new attributes:
      attribute :satisfying_rate, :float
      scope :includes_satisfying_rate, -> (period:) do
        from(includes_satisfaction_counts(period: period), self.table_name)
          .select(<<~SQL.squish
            *,
            satisfying_count::FLOAT / company_satisfactions_count::FLOAT AS satisfying_rate
          SQL
                 )
      end

      # Compute company_satisfaction count per antenne
      # The returned collection has these additional new attributes:
      attribute :company_satisfactions_count, :integer
      attribute :contacted_by_expert_count, :integer
      attribute :useful_exchange_count, :integer
      attribute :satisfying_count, :integer
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
