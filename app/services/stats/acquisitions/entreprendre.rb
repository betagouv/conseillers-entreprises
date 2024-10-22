module Stats::Acquisitions
  class Entreprendre
    include ::Stats::BaseStats
    include Stats::Needs::Base

    def main_query
      needs_base_scope
        .joins(diagnosis: :solicitation)
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @needs_from_entreprendre = []
      @from_others = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        from_entreprendre_count = month_query.where(solicitations: Solicitation.mtm_campaign_eq('entreprendre')).count
        @needs_from_entreprendre << from_entreprendre_count
        @from_others << month_query.count - from_entreprendre_count
      end

      as_series(@needs_from_entreprendre)
    end

    def chart
      'line-chart'
    end

    def count
      build_series
      percentage_two_numbers(@needs_from_entreprendre, @from_others)
    end

    def secondary_count
      @needs_from_entreprendre.sum
    end

    def colors
      needs_colors
    end



    private

    def as_series(from_entreprendre)
      [
        {
          name: I18n.t('stats.series.from_entreprendre.title'),
          data: from_entreprendre
        }
      ]
    end
  end
end
