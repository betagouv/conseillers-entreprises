module Stats::Quality
  class NeedsDoneNotReachableStats
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

      @needs_not_reachable ||= not_reachable(query)
      @needs_other_status ||= other_status(query)

      as_series(@needs_not_reachable, @needs_other_status)
    end

    def not_reachable(query)
      query.where(status: :done_not_reachable).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def other_status(query)
      query.where.not(status: :done_not_reachable).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def count
      build_series
      percentage_two_numbers(@needs_not_reachable, @needs_other_status)
    end

    private

    def as_series(needs_not_reachable, needs_other_status)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_other_status
        },
        {
          name: I18n.t('stats.status_done_not_reachable'),
          data: needs_not_reachable
        }
      ]
    end
  end
end
