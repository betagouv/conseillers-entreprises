module Stats::Matches
  class TransmittedLessThan72hStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.joins(:diagnoses).status_processed.all
    end

    def filtered(query)
      if territory.present?
        query.merge! query.by_possible_territory(territory.id)
      end
      if institution.present?
        query.merge! institution.received_needs
      end
      if @start_date.present?
        query.where!(created_at: @start_date..@end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)
      query = group_by_date(query)
      @less_than_72h ||= query[true].group_by_month(&:created_at).map { |_, v| v.size }
      @more_than_72h ||= query[false].group_by_month(&:created_at).map { |_, v| v.size }
      as_series(@less_than_72h, @more_than_72h)
    end

    def group_by_date(query)
      query.group_by do |solicitation|
        solicitation.transmitted_at&.between?(solicitation.created_at, solicitation.created_at + 3.days)
      end
    end

    def count
      build_series
      percentage_two_numbers(@less_than_72h, @more_than_72h)
    end

    private

    def as_series(less_than_72h, more_than_72h)
      [
        {
          name: I18n.t('stats.more_than_72h'),
          data: more_than_72h
        },
        {
          name: I18n.t('stats.less_than_72h'),
          data: less_than_72h
        }
      ]
    end
  end
end
