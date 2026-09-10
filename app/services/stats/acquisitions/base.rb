module Stats::Acquisitions::Base
  include Stats::Concerns::FilteredAggregates

  def build_series
    build_filtered_series
  end

  def aggregate_filters
    {
      from_entreprendre: Solicitation.mtm_campaign_cont_sql('entreprendre'),
      from_google_ads: Solicitation.mtm_campaign_cont_sql('googleads'),
      from_iframes: Solicitation.from_integration_sql(:iframe),
      from_redirections: "(#{Solicitation.mtm_campaign_cont_sql('orientation-partenaire')} OR " \
                         "#{Solicitation.mtm_campaign_cont_sql('compartenaire')})",
      from_api: Solicitation.from_integration_sql(:api),
    }
  end

  def with_others?
    chart == 'percentage-column-chart'
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
end
