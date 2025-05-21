module Stats::Needs
  class Requalification
    include Stats::Needs::Base

    def main_query
      # This stat is available since 2020-09-01
      needs_base_scope
        .where(created_at: Time.zone.local(2020, 9, 1)..)
    end

    def build_series
      query = filtered_main_query

      @needs_requalified = []
      @needs_not_requalified = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @needs_requalified.push(month_query.requalified.count)
        @needs_not_requalified.push(month_query.not_requalified.count)
      end

      as_series(@needs_requalified, @needs_not_requalified)
    end

    def subtitle
      nil
    end

    def count
      series
      percentage_two_numbers(@needs_requalified, @needs_not_requalified)
    end

    def secondary_count
      @secondary_count ||= filtered_main_query.requalified.size
    end

    private

    def as_series(needs_requalified, needs_not_requalified)
      [
        {
          name: I18n.t('stats.series.needs_requalification.not_requalified'),
          data: needs_not_requalified
        },
        {
          name: I18n.t('stats.series.needs_requalification.requalified'),
          data: needs_requalified
        }
      ]
    end
  end
end
