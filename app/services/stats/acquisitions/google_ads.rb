module Stats::Acquisitions
  class GoogleAds
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_from_google = []
      @from_others = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        from_google_count = month_query.from_campaign('googleads').count
        @needs_from_google << from_google_count
        @from_others << (month_query.count - from_google_count)
      end

      as_series(@needs_from_google)
    end

    def count
      series
      percentage_two_numbers(@needs_from_google, @from_others)
    end

    def secondary_count
      @needs_from_google.sum
    end

    private

    def as_series(needs)
      [
        {
          name: I18n.t('stats.series.from_google_ads.title'),
          data: needs
        }
      ]
    end
  end
end
