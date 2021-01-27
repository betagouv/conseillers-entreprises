module Stats::Public
  class SolicitationsDiagnosesStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.all
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
      if institution.present?
        query.merge! institution.received_solicitations
      end
      if @start_date.present?
        query = query.where("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @with_diagnoses ||= with_diagnoses(query).values
      @without_diagnoses ||= without_diagnoses(query).values

      as_series(@with_diagnoses, @without_diagnoses)
    end

    def count
      build_series
      percentage_two_numbers(@with_diagnoses, @without_diagnoses)
    end

    def subtitle
      I18n.t('stats.series.solicitations_diagnoses.subtitle_html')
    end

    private

    def as_series(with_diagnoses, without_diagnoses)
      [
        {
          name: I18n.t('stats.without_diagnoses'),
            data: without_diagnoses
        },
        {
          name: I18n.t('stats.with_diagnoses'),
            data: with_diagnoses
        }
      ]
    end
  end
end
