module Stats::Acquisitions
  class OverallDistributionSolicitations
    include Stats::Acquisitions::SolicitationsBase

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query, self).call

      @results = Hash.new { |hash, key| hash[key] = [] }

      search_range_by_month.each do |range|
        build_range_data(query, range)
      end

      as_series(@results)
    end

    def colors
      lines_colors
    end
  end
end
