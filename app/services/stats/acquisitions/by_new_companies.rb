module Stats::Acquisitions
  class ByNewCompanies
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsBase

    def main_query
      base_scope.where(status: :done).joins(:solicitation)
    end

    def first_solicitations
      Solicitation.joins(diagnosis: :facility)
        .group('facilities.id')
        .select('min(solicitations.id) as id')
    end

    def build_series
      query = filtered_main_query
      @from_new_companies = []
      @from_known_companies = []

      search_range_by_month.each do |range|
        month_query = month_query(query, range)
        @from_new_companies.push(month_query
                                   .where(solicitations: { id: first_solicitations })
                                   .count)
        @from_known_companies.push(month_query
                                     .where.not(solicitations: { id: first_solicitations })
                                     .count)
      end

      as_series(@from_known_companies, @from_new_companies)
    end

    def month_query(query, range)
      query.created_between(range.first, range.last)
    end

    def as_series(from_known_companies, from_new_companies)
      [
        {
          name: I18n.t('stats.from_known_companies'),
          data: from_known_companies
        },
        {
          name: I18n.t('stats.from_new_companies'),
          data: from_new_companies
        }
      ]
    end

    def count
      series
      percentage_two_numbers(@from_new_companies, @from_known_companies)
    end

    def secondary_count
      series
      @from_new_companies.sum
    end

    def colors
      %w[#F15C80 #9F3BCA]
    end

    def chart
      'percentage-column-chart'
    end
  end
end
