module Monitoring
  extend ActiveSupport::Concern

  # Additional scopes based on the :received_matches relation. (For Expert, User, Antenne or Institution)
  # Efficiently compute the count and rate of done or not_for_me (using matches) or the satisfying rate (using company_satisfaction).

  ## Constants for high-level scopes
  MATCHES_PERIOD = TimeDurationService::Quarters.new.call.first
  MATCHES_COUNT = (50..)
  MATCHES_NOT_FOR_ME_RATE = (0.3..)
  MATCHES_DONE_RADE = (..0.25)

  SOLICITATIONS_PERIOD = TimeDurationService::Years.new.call.first
  SOLICITATIONS_COUNT = (100..)
  SOLICITATIONS_SATISFYING_RATE = (..0.45)

  # Attributes automatically added to the records using these scopes
  MONITORING_ATTRIBUTES = %i[
    received_matches_count not_for_me_count not_for_me_rate done_count done_rate
    company_satisfactions_count satisfying_count satisfying_rate
  ]
  included do
    MONITORING_ATTRIBUTES.each { |name| attribute name }

    ## High-level monitoring scopes
    # These three scopes rely on the implementation below to filter on the match status of satisfaction rates
    scope :often_not_for_me, -> do
      from(includes_match_status_rates(period: MATCHES_PERIOD), self.table_name)
        .where(received_matches_count: MATCHES_COUNT)
        .where(not_for_me_rate: MATCHES_NOT_FOR_ME_RATE)
    end

    scope :rarely_done, -> do
      from(includes_match_status_rates(period: MATCHES_PERIOD), self.table_name)
        .where(received_matches_count: MATCHES_COUNT)
        .where(done_rate: MATCHES_DONE_RADE)
    end

    scope :rarely_satisfying, -> do
      from(includes_satisfying_rate(period: SOLICITATIONS_PERIOD), self.table_name)
        .where(company_satisfactions_count: SOLICITATIONS_COUNT)
        .where(satisfying_rate: SOLICITATIONS_SATISFYING_RATE)
    end

    ## Low-level monitoring scopes
    # These scopes join / group by / count the received matches and compute the results as additional columns.
    # /!\ The second parameter of the #from calls is essential for the calling scope to properly work.

    # Compute match status rates
    # The returned collection has these additional new attributes:
    # :done_rate, :not_for_me_rate
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
    # :received_matches_count, :done_count, :not_for_me_count
    scope :includes_match_status_counts, -> (period:) do
      joins(:received_matches)
        .where(matches: { sent_at: period })
        .group(:id)
        .select(<<~SQL.squish
          "#{self.table_name}".*,
          COUNT(matches.id) AS received_matches_count,
          SUM(CASE WHEN matches.status IN ('done') THEN 1 ELSE 0 END) AS done_count,
          SUM(CASE WHEN matches.status IN ('not_for_me') THEN 1 ELSE 0 END) AS not_for_me_count
        SQL
               )
    end

    # Compute company satisfaction rate
    # The returned collection has these additional new attributes:
    # :satisfying_rate
    scope :includes_satisfying_rate, -> (period:) do
      from(includes_satisfaction_counts(period: period), self.table_name)
        .select(<<~SQL.squish
          *,
          satisfying_count::FLOAT / company_satisfactions_count::FLOAT AS satisfying_rate
        SQL
               )
    end

    # Compute company_satisfaction count per record
    # The returned collection has these additional new attributes:
    # :company_satisfactions_count, :contacted_by_expert_count, :useful_exchange_count, :satisfying_count
    scope :includes_satisfaction_counts, -> (period:) do
      joins(received_matches: { need: :company_satisfaction })
        .where(matches: { status: :done })
        .where(matches: { sent_at: period })
        .group(:id)
        .select(<<~SQL.squish
          "#{self.table_name}".*,
          COUNT(company_satisfactions.id) AS company_satisfactions_count,
          COUNT(CASE company_satisfactions.contacted_by_expert WHEN TRUE THEN 1 ELSE NULL END) AS contacted_by_expert_count,
          COUNT(CASE company_satisfactions.useful_exchange WHEN TRUE THEN 1 ELSE NULL END) AS useful_exchange_count,
          COUNT(CASE company_satisfactions.contacted_by_expert AND company_satisfactions.useful_exchange WHEN TRUE THEN 1 ELSE NULL END) AS satisfying_count
        SQL
               )
    end
  end
end
