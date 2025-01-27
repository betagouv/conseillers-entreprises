module Stats::Needs
  class DoneNoHelp
    include Stats::Needs::Base

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_done_no_help = []
      @needs_others_status = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        done_no_help_query = month_query.where(status: :done_no_help)
        others_status_query = month_query.where.not(status: :done_no_help)
        @needs_done_no_help.push(done_no_help_query.count)
        @needs_others_status.push(others_status_query.count)
      end

      as_series(@needs_done_no_help, @needs_others_status)
    end

    def with_help(query)
      query.where(status: :done_no_help).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def without_help(query)
      query.where.not(status: :done_no_help).group_by_month(&:created_at).map { |_, v| v.size }
    end

    def count
      series
      percentage_two_numbers(@needs_done_no_help, @needs_others_status)
    end

    def secondary_count
      @secondary_count ||= filtered_main_query.status_done_no_help.size
    end

    private

    def as_series(needs_with_help, needs_without_help)
      [
        {
          name: I18n.t('stats.other_status'),
          data: needs_without_help
        },
        {
          name: I18n.t('stats.status_done_no_help'),
          data: needs_with_help
        }
      ]
    end
  end
end
