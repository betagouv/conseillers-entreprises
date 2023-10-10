module Stats::Solicitations
  class SolicitationsDiagnosesStats
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date)
    end

    def build_series
      query = filtered_main_query

      @with_diagnosis = []
      @without_diagnosis = []
      search_range_by_month.each do |range|
        month_query = query.where(completed_at: range.first.beginning_of_day..range.last.end_of_day)
        with_diagnosis_query = month_query.joins(:diagnosis).merge(Diagnosis.completed)
        without_diagnosis_query = month_query.without_diagnosis.or(month_query.left_outer_joins(:diagnosis).merge(Diagnosis.in_progress))
        @with_diagnosis.push(with_diagnosis_query.count)
        @without_diagnosis.push(without_diagnosis_query.count)
      end

      as_series(@with_diagnosis, @without_diagnosis)
    end

    def filtered_main_query
      filtered_solicitations(main_query)
    end

    def secondary_count
      filtered_main_query.joins(:diagnosis).merge(Diagnosis.completed).size
    end

    def count
      build_series
      percentage_two_numbers(@with_diagnosis, @without_diagnosis)
    end

    def subtitle
      I18n.t('stats.series.solicitations_diagnoses.subtitle_html')
    end

    private

    def as_series(with_diagnosis, without_diagnosis)
      [
        {
          name: I18n.t('stats.without_diagnosis'),
            data: without_diagnosis
        },
        {
          name: I18n.t('stats.with_diagnosis'),
            data: with_diagnosis
        }
      ]
    end
  end
end
