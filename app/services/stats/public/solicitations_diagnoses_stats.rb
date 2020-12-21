module Stats::Public
  class SolicitationsDiagnosesStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.all
    end

    def date_group_attribute
      'solicitations.created_at'
    end

    def with_diagnoses(query)
      query
        .joins(:diagnoses)
        .where.not('diagnoses.id' => nil)
        .group_by_month(date_group_attribute)
        .count
    end

    def without_diagnoses(query)
      query
        .left_outer_joins(:diagnoses)
        .where('diagnoses.id IS NULL')
        .group_by_month(date_group_attribute)
        .count
    end

    def filtered(query)
      if @start_date.present?
        query = query.where("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      with_diagnoses = with_diagnoses(query)
      without_diagnoses = without_diagnoses(query)

      as_series(with_diagnoses, without_diagnoses)
    end

    def count
      solicitations = build_series
      without_diagnoses_sum = solicitations[0][:data].sum
      with_diagnoses_sum = solicitations[1][:data].sum
      sum = with_diagnoses_sum + without_diagnoses_sum
      sum != 0 ? "#{with_diagnoses_sum * 100 / sum}%" : "0"
    end

    def format
      '{series.name} : <b>{point.percentage:.0f}%</b>'
    end

    def chart
      'percentage-column-chart'
    end

    def subtitle
      I18n.t('stats.series.solicitations_diagnoses.subtitle')
    end

    private

    def as_series(with_diagnoses, without_diagnoses)
      [
        {
          name: I18n.t('stats.without_diagnoses'),
            data: without_diagnoses.values
        },
        {
          name: I18n.t('stats.with_diagnoses'),
            data: with_diagnoses.values
        }
      ]
    end
  end
end
