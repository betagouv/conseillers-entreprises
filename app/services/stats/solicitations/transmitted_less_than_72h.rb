module Stats::Solicitations
  class TransmittedLessThan72h
    include ::Stats::BaseStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      Solicitation.joins(diagnosis: :needs).status_processed.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      Stats::Filters::Solicitations.new(query, self).call
    end

    # series[0] = more_than_72h (compared), series[1] = less_than_72h (target).
    # Rows keep the diagnosis->needs join fan-out (plain COUNT, no distinct) as
    # before; solicitations without a transmission date (NULL completed_at) fall
    # out of both buckets, mirroring the original nil group.
    def category_buckets
      within_72h = 'diagnoses.completed_at BETWEEN solicitations.created_at ' \
                   "AND solicitations.created_at + INTERVAL '3 days'"
      [
        [:more_than_72h, "NOT (#{within_72h})"],
        [:less_than_72h, within_72h]
      ]
    end

    def category_name(key)
      key == 'less_than_72h' ? I18n.t('stats.less_than_72h') : I18n.t('stats.more_than_72h')
    end

    def count
      @count ||= percentage_two_numbers(series[1][:data], series[0][:data])
    end
  end
end
