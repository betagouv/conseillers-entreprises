module Stats::Acquisitions::NeedsBase
  include Stats::Acquisitions::Base

  def base_scope
    Need.diagnosis_completed
      .joins(diagnosis: { solicitation: :landing }).merge(Diagnosis.from_solicitation)
      .where(created_at: @start_date..@end_date)
  end

  def build_columns_series
    query = main_query
    query = Stats::Filters::Needs.new(query, self).call

    @results = Hash.new { |hash, key| hash[key] = [] }
    @results['from_others'] = []

    search_range_by_month.each do |range|
      month_query = query.created_between(range.first, range.last)

      from_entreprendre = month_query.from_campaign('entreprendre')
      from_google_ads = month_query.from_campaign('googleads')
      from_iframes = month_query.from_integration('iframe')
      from_redirections = month_query.from_campaign('orientation-partenaire').or(month_query.from_campaign('compartenaire'))
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

  def build_lines_series
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
