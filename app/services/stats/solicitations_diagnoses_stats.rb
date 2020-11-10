module Stats
  class SolicitationsDiagnosesStats
    include BaseStats

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

    private

    def as_series(with_diagnoses, without_diagnoses)
      [
        {
          name: I18n.t('stats.with_diagnoses'),
            data: with_diagnoses.values
        },
        {
          name: I18n.t('stats.without_diagnoses'),
            data: without_diagnoses.values
        }
      ]
    end
  end
end
