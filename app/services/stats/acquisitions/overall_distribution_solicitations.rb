module Stats::Acquisitions
  class OverallDistributionSolicitations
    include ::Stats::BaseStats
    include Stats::Acquisitions::Base

    def main_query
      solicitations_main_query
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @results = Hash.new { |hash, key| hash[key] = [] }

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @results['from_entreprendre'] << month_query.mtm_campaign_cont('entreprendre').count
        @results['from_google_ads'] << month_query.mtm_campaign_cont('googleads').count
        @results['from_iframes'] << month_query.from_integration('iframe').count
        @results['from_redirections'] << month_query.mtm_campaign_cont('orientation-partenaire').or(month_query.mtm_campaign_cont('compartenaire')).count
        @results['from_api'] << month_query.from_integration('api').count
      end

      as_series(@results)
    end

    def colors
      lines_colors
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
