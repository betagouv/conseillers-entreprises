module Stats::Quality
  class NeedsDoneStats
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
    end

    def filtered(query)
      if territory.present?
        query.merge! territory.needs
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      if @start_date.present?
        query.where!(needs: { created_at: @start_date..@end_date })
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @needs_with_help ||= with_help(query)
      @needs_without_help ||= without_help(query)

      as_series(@needs_with_help, @needs_without_help)
    end

    def with_help(query)
      query.where(status: :done).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def without_help(query)
      query.where.not(status: :done).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def count
      build_series
      percentage_two_numbers(@needs_with_help, @needs_without_help)
    end

    private

    def as_series(needs_with_help, needs_without_help)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_without_help
        },
        {
          name: I18n.t('stats.status_done'),
          data: needs_with_help
        }
      ]
    end
  end
end
