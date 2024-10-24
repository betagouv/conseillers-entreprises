module Stats::Acquisitions
  class Entreprendre
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_from_entreprendre = []
      @from_others = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        from_entreprendre_count = month_query.from_campaign('entreprendre').count
        @needs_from_entreprendre << from_entreprendre_count
        @from_others << (month_query.count - from_entreprendre_count)
      end

      as_series(@needs_from_entreprendre)
    end

    def count
      build_series
      percentage_two_numbers(@needs_from_entreprendre, @from_others)
    end

    def secondary_count
      @needs_from_entreprendre.sum
    end

    private

    def as_series(from_entreprendre)
      [
        {
          name: I18n.t('stats.series.from_entreprendre.title'),
          data: from_entreprendre
        }
      ]
    end
  end
end
