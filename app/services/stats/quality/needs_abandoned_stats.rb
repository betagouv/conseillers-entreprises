module Stats::Quality
  class NeedsAbandonedStats
    include ::Stats::BaseStats

    def main_query
      Need.diagnosis_completed
    end

    def date_group_attribute
      'needs.created_at'
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

      needs_archived = with_help(query)
      needs_not_archived = not_archived(query)

      as_series(needs_archived, needs_not_archived)
    end

    def with_help(query)
      query.archived(true).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def not_archived(query)
      query.archived(false).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def count
      needs = build_series
      percentage_two_numbers(needs[1][:data], needs[0][:data])
    end

    def format
      '{series.name} : <b>{point.percentage:.0f}%</b>'
    end

    def chart
      'percentage-column-chart'
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
