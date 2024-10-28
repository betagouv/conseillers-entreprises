module Stats::Acquisitions
  class OverallDistributionColumn
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def main_query
      needs_base_scope
        .joins(diagnosis: { solicitation: :landing })
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @results = Hash.new { |hash, key| hash[key] = [] }
      @results['from_others'] = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        from_entreprendre = month_query.from_campaign('entreprendre')
        @results['from_entreprendre'] << from_entreprendre.count
        from_google = month_query.from_campaign('googleads')
        @results['from_google_ads'] << from_google.count
        from_iframes = month_query.from_integration('iframe')
        @results['from_iframes'] << from_iframes.count
        from_redirections = month_query.from_campaign('orientation-partenaire').or(month_query.from_campaign('compartenaire'))
        @results['from_redirections'] << from_redirections.count
        from_api = month_query.from_integration('api')
        @results['from_api'] << from_api.count

        month_query = month_query - (from_entreprendre + from_google + from_iframes + from_redirections + from_api)
        @results['from_others'] << month_query.count
      end

      as_series(@results)
    end

    def count; end

    def colors
      %w[#cecece #c9191e #F1C40F #AFD2E9 #A8C256 #345995]
    end

    def chart
      'percentage-column-chart'
    end

    private

    def as_series(from_entreprendre)
      from_entreprendre.map do |key, value|
        {
          name: I18n.t("stats.series.#{key}.title"),
          data: value
        }
      end
    end
  end
end
