# frozen_string_literal: true

module PositionningRate
  class Collection
    include Base

    def initialize(experts, start_date = DEFAULT_START_DATE, end_date = DEFAULT_END_DATE)
      @experts = experts
      @start_date = start_date
      @end_date = end_date
    end

    def critical_rate
      base_query
        .where("(#{sql_received_quo_matches_count}) / cast((#{sql_received_matches_count}) as float) >= ?", CRITICAL_RATE)
      end

    def worrying_rate
      base_query
        .where("(#{sql_received_quo_matches_count}) / cast((#{sql_received_matches_count}) as float) >= ? AND (#{sql_received_quo_matches_count}) / cast((#{sql_received_matches_count}) as float) < ?", WORRYING_RATE, CRITICAL_RATE)
  end

    def pending_rate
      base_query
        .where.not(id: critical_rate.pluck(:id) + worrying_rate.pluck(:id))
    end

    # Ici dans une logique de debug, pour le moment
    def rates
      base_query.select("experts.*,
        (#{sql_received_quo_matches_count}) as quo_count,
        (#{sql_received_matches_count}) as normal_count,
        (#{sql_received_quo_matches_count}) / cast((#{sql_received_matches_count}) as float) as rate")
    end

    private

    def base_query
      @experts
        .not_deleted
        .joins(:received_quo_matches) # Pour ne pas avoir de division avec zéro
        .merge(Match.created_between(@start_date, @end_date))
    end

    def sql_received_matches_count
      "SELECT COUNT(*) FROM matches
        WHERE matches.expert_id = experts.id
        AND matches.created_at BETWEEN '#{@start_date}' AND '#{@end_date}'
        AND matches.id IN (SELECT matches.id FROM matches INNER JOIN needs ON needs.id = matches.need_id INNER JOIN diagnoses ON diagnoses.id = needs.diagnosis_id WHERE diagnoses.step = #{Diagnosis.steps['completed']})"
    end

    def sql_received_quo_matches_count
      sql_received_matches_count + " AND matches.status = 'quo'"
    end
  end
end
