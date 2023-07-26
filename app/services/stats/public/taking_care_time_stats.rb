module Stats::Public
  class TakingCareTimeStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats
    require 'benchmark'
    include Benchmark
    def main_query
      Solicitation
        .step_complete
        .joins(diagnosis: [needs: :matches])
        .where(completed_at: @start_date..@end_date)
        .merge(Need.with_exchange)
        .distinct
    end

    def group_by_date(query)
      response = { true: 0, false: 0 }
      duration = Benchmark.realtime do
        # Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
        # si un match a été pris en charge entre la date de création de la demande et 5 jours après
        # query.select("COUNT(DISTINCT solicitations.id) AS count
        # FROM Solicitations
        # INNER JOIN diagnoses ON diagnoses.solicitation_id = solicitations.id
        # INNER JOIN needs ON needs.diagnosis_id = diagnoses.id
        # INNER JOIN matches ON matches.need_id = needs.id
        # WHERE MIN(matches.taken_care_of_at) BETWEEN solicitations.completed_at AND (solicitations.completed_at + INTERVAL '5 DAY'")

        # Solicitation.select('COUNT(DISTINCT solicitations.id) FROM Solicitations
        # INNER JOIN diagnoses ON diagnoses.solicitation_id = solicitations.id
        # INNER JOIN needs ON needs.diagnosis_id = diagnoses.id
        # INNER JOIN matches ON matches.need_id = needs.id
        # GROUP BY solicitations.id
        # HAVING MIN(matches.taken_care_of_at) BETWEEN solicitations.completed_at AND DATEADD(day, 5, solicitations.completed_at);')
        #
        # query.select('COUNT(DISTINCT solicitations.id) AS solicitation_count')
        query.joins('
                INNER JOIN diagnoses ON diagnoses.solicitation_id = solicitations.id
                INNER JOIN needs ON needs.diagnosis_id = diagnoses.id
                INNER JOIN matches ON matches.need_id = needs.id
                ')
             .where('MIN(matches.taken_care_of_at) BETWEEN solicitations.completed_at AND solicitations.completed_at + INTERVAL 5 DAY')

        query.includes(:matches).each do |solicitation|
          good_matches = solicitation.matches.pluck(:taken_care_of_at).compact.min&.between?(solicitation.completed_at, solicitation.completed_at + 5.days)
          good_matches ? response[:true] += 1 : response[:false] += 1
        end
      end
      puts "DEBUG group_by_date Taken: #{duration}"
      response
    end

    def group_by_date_in_range(query, range)
      query_range = query.created_between(range.first, range.last)
      group_by_date(query_range)
    end

    def series
      @series ||= build_series
    end

    def build_series
      query = main_query
      query = filtered_needs(query)

      @taken_care_before = []
      @taken_care_after = []

      duration = Benchmark.realtime do
        search_range_by_month.each do |range|
          grouped_result = group_by_date_in_range(query, range)
          @taken_care_before.push(grouped_result[:true])
          @taken_care_after.push(grouped_result[:false])
        end
      end
      puts "DEBUG build_series Taken: #{duration}"

      as_series(@taken_care_before, @taken_care_after)
    end

    def max_value
      100
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def count
      series
      @count ||= percentage_two_numbers(@taken_care_before, @taken_care_after)
    end

    private

    def as_series(taken_care_before, taken_care_after)
      [
        {
          name: I18n.t('stats.taken_care_after'),
          data: taken_care_after
        },
        {
          name: I18n.t('stats.taken_care_before'),
          data: taken_care_before
        }
      ]
    end
  end
end
