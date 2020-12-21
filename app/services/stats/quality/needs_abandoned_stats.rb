module Stats::Quality
  class NeedsAbandonedStats
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

      @needs_archived ||= archived(query)
      @needs_not_archived ||= not_archived(query)

      as_series(@needs_archived, @needs_not_archived)
    end

    def archived(query)
      query.archived(true).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def not_archived(query)
      query.archived(false).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def count
      build_series
      percentage_two_numbers(@needs_archived, @needs_not_archived)
    end

    private

    def as_series(needs_archived, needs_not_archived)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_not_archived
        },
        {
          name: I18n.t('stats.archived'),
          data: needs_archived
        }
      ]
    end
  end
end
