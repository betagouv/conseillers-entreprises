module Stats::Needs
  # Besoins mis en relation
  class Transmitted
    include Stats::Needs::Base

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    # Single distinct-count series, one grouped query instead of one per month.
    def build_series
      counts = grouped_by_month(filtered(main_query)).distinct.count(:id)
      by_month = counts.transform_keys { |month| month.to_date.beginning_of_month }
      [{ name: I18n.t('stats.series.transmitted_needs.title'), data: all_months.map { |month| by_month[month] || 0 } }]
    end

    def chart
      'column-chart'
    end

    def colors
      needs_colors
    end

    def format
      '{series.name} : <b>{point.y}</b>'
    end
  end
end
