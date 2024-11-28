module Stats::Needs
  # Besoins mis en relation
  class Transmitted
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
    end

    def filtered(query)
      Stats::Filters::Needs.new(query, self).call
    end

    def build_series
      query = filtered(main_query)

      @needs = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @needs.push(month_query.count)
      end

      as_series(@needs)
    end

    def chart
      'column-chart'
    end

    def colors
      needs_colors
    end

    def format
      '{series.name} : <b>{point.y}</b>'
    end

    private

    def as_series(needs)
      [
        {
          name: I18n.t('stats.series.transmitted_needs.title'),
          data: needs
        }
      ]
    end
  end
end
