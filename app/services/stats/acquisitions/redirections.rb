module Stats::Acquisitions
  class Redirections
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_from_redirections = []
      @from_others = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        from_redirections_count = month_query.from_campaign('orientation-partenaire')
          .or(month_query.from_campaign('compartenaire')).count
        @needs_from_redirections << from_redirections_count
        @from_others << (month_query.count - from_redirections_count)
      end

      as_series(@needs_from_redirections)
    end

    def count
      series
      percentage_two_numbers(@needs_from_redirections, @from_others)
    end

    def secondary_count
      @needs_from_redirections.sum
    end

    private

    def as_series(from_redirections)
      [
        {
          name: I18n.t('stats.series.from_redirections.title'),
          data: from_redirections
        }
      ]
    end
  end
end
