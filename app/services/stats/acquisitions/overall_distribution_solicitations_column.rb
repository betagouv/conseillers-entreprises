module Stats::Acquisitions
  class OverallDistributionSolicitationsColumn
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def main_query
      solicitations_main_query
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @results = Hash.new { |hash, key| hash[key] = [] }
      @results['from_others'] = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)

        from_entreprendre = month_query.mtm_campaign_cont('entreprendre')
        from_google_ads = month_query.mtm_campaign_cont('googleads')
        from_iframes = month_query.from_integration('iframe')
        from_redirections = month_query.mtm_campaign_cont('orientation-partenaire').or(month_query.mtm_campaign_cont('compartenaire'))
        from_api = month_query.from_integration('api')

        @results['from_entreprendre'] << from_entreprendre.count
        @results['from_google_ads'] << from_google_ads.count
        @results['from_iframes'] << from_iframes.count
        @results['from_redirections'] << from_redirections.count
        @results['from_api'] << from_api.count
        @results['from_others'] << (month_query - (from_entreprendre + from_google_ads + from_iframes + from_redirections + from_api)).count
      end

      as_series(@results)
    end

    def colors
      columns_colors
    end

    def chart
      'percentage-column-chart'
    end

    private

    def as_series(results)
      results.map do |key, value|
        {
          name: I18n.t("stats.series.#{key}.title"),
          data: value
        }
      end
    end
  end
end
