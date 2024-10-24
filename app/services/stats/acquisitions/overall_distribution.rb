module Stats::Acquisitions
  class OverallDistribution
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

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @results['from_entreprendre'] << month_query.from_campaign('entreprendre').count
        @results['from_google_ads'] << month_query.from_campaign('googleads').count
        @results['from_iframes'] << month_query.from_integration('iframe').count
        @results['from_redirections'] << month_query.from_campaign('orientation-partenaire').or(month_query.from_campaign('compartenaire')).count
        @results['from_api'] << month_query.from_integration('api').count
      end

      as_series(@results)
    end

    def count; end

    def colors
      %w[#c9191e #F1C40F #AFD2E9 #A8C256 #345995]
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
