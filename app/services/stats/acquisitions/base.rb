module Stats::Acquisitions::Base
  def build_series_for_type(type)
    query = main_query
    query = filtered(query)

    @results = Hash.new { |hash, key| hash[key] = [] }
    @results['from_others'] = [] if type == 'percentage-column-chart'

    search_range_by_month.each do |range|
      if type == 'percentage-column-chart'
        build_range_data_with_others(query, range)
      else
        build_range_data(query, range)
      end
    end

    as_series(@results)
  end

  def build_range_data(query, range)
    month_query = month_query(query, range)
    @results['from_entreprendre'] << month_query.mtm_campaign_cont('entreprendre').count
    @results['from_google_ads'] << month_query.mtm_campaign_cont('googleads').count
    @results['from_iframes'] << month_query.from_integration('iframe').count
    @results['from_redirections'] << month_query.mtm_campaign_cont('orientation-partenaire')
      .or(month_query.mtm_campaign_cont('compartenaire')).count
    @results['from_api'] << month_query.from_integration('api').count
  end

  def build_range_data_with_others(query, range)
    build_range_data(query, range)
    @results['from_others'] << (month_query(query, range).count - @results['from_entreprendre'].last - @results['from_google_ads'].last -
      @results['from_iframes'].last - @results['from_redirections'].last - @results['from_api'].last)
  end

  def category_group_attribute
    :status
  end

  def count; end

  def chart
    'line-chart'
  end

  def colors
    needs_colors
  end

  def lines_colors
    %w[#c9191e #F1C40F #AFD2E9 #A8C256 #345995]
  end

  def columns_colors
    %w[#cecece #c9191e #F1C40F #AFD2E9 #A8C256 #345995]
  end

  private

  def month_query(query, range)
    query.created_between(range.first, range.last)
  end
end
