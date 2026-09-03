module Stats::Acquisitions::Base
  include Stats::Concerns::FilteredAggregates

  def build_series
    build_filtered_series
  end

  # Ordered series (insertion order = display order). Buckets are independent:
  # a solicitation can match several, exactly like the previous per-month counts.
  def aggregate_filters
    {
      from_entreprendre: campaign_condition('entreprendre'),
      from_google_ads: campaign_condition('googleads'),
      from_iframes: integration_condition(:iframe),
      from_redirections: "(#{campaign_condition('orientation-partenaire')} OR #{campaign_condition('compartenaire')})",
      from_api: integration_condition(:api),
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

  private

  def campaign_condition(value)
    "(solicitations.form_info::json->>'pk_campaign' ILIKE '%#{value}%' " \
      "OR solicitations.form_info::json->>'mtm_campaign' ILIKE '%#{value}%')"
  end

  def integration_condition(integration)
    "solicitations.landing_id IN (#{Landing.where(integration: integration).select(:id).to_sql})"
  end
end
