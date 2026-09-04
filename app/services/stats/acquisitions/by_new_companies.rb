module Stats::Acquisitions
  class ByNewCompanies
    include ::Stats::BaseStats
    include Stats::Acquisitions::NeedsScope
    include ::Stats::TwoRatesStats
    include Stats::Concerns::PartitionedCategory

    def main_query
      base_scope.where(status: :done).joins(:solicitation)
    end

    def first_solicitations
      Solicitation.joins(diagnosis: :facility)
        .group('facilities.id')
        .select('min(solicitations.id) as id')
    end

    # series[0] = from_known_companies (compared), series[1] = from_new_companies (target)
    def category_buckets
      [
        [:from_known_companies, :else],
        [:from_new_companies, "solicitations.id IN (#{first_solicitations.to_sql})"]
      ]
    end

    def category_name(key)
      I18n.t("stats.#{key}")
    end

    def colors
      %w[#F15C80 #9F3BCA]
    end

    def chart
      'percentage-column-chart'
    end
  end
end
