# frozen_string_literal: true

module PositionningRate
  class Member
    include Base

    def initialize(expert, start_date = DEFAULT_START_DATE, end_date = DEFAULT_END_DATE)
      @expert = expert
      @start_date = start_date
      @end_date = end_date
    end

    def rate
      if received_matches_count == 0 || received_quo_matches_count == 0
        @member_rate ||= 0
      else
        @member_rate ||= (received_quo_matches_count.to_f / received_matches_count)
      end
    end

    def critical_rate?
      rate > CRITICAL_RATE
    end

    def worrying_rate?
      rate > WORRYING_RATE
    end

    def pending_rate?
      rate <= WORRYING_RATE
    end

    private

    def received_matches
      @received_matches ||= @expert.received_matches.created_between(@start_date, @end_date)
    end

    def received_matches_count
      @received_matches_count ||= received_matches.count
    end

    def received_quo_matches_count
      @received_quo_matches_count ||= received_matches.status_quo.count
    end
  end
end
