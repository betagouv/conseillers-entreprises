module Stats::Solicitations
  class Diagnoses
    include ::Stats::BaseStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      Solicitation.step_complete.where(completed_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Solicitations.new(query, self).call
    end

    def date_group_attribute
      'completed_at'
    end

    # series[0] = without_diagnosis (compared), series[1] = with_diagnosis (target).
    # "without" is the complement of a completed diagnosis (no diagnosis or one
    # still in progress), so :else reproduces the original union exactly.
    def category_buckets
      [
        [:without_diagnosis, :else],
        [:with_diagnosis, completed_diagnosis_exists_sql]
      ]
    end

    def category_name(key)
      key == 'with_diagnosis' ? I18n.t('stats.with_diagnosis') : I18n.t('stats.without_diagnosis')
    end

    def count
      @count ||= percentage_two_numbers(series[1][:data], series[0][:data])
    end

    # Uses the same EXISTS as category_buckets so a solicitation with several
    # completed diagnoses (no unique constraint on diagnoses.solicitation_id)
    # is counted once here too, matching count/series instead of duplicating
    # it as a JOIN would.
    def secondary_count
      @secondary_count ||= filtered_main_query.where(completed_diagnosis_exists_sql).size
    end

    def subtitle
      I18n.t('stats.series.solicitations_diagnoses.subtitle_html')
    end

    private

    def completed_diagnosis_exists_sql
      <<~SQL.squish
        EXISTS (SELECT 1 FROM diagnoses d
                WHERE d.solicitation_id = solicitations.id AND d.step = #{Diagnosis.steps[:completed]})
      SQL
    end
  end
end
