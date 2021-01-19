module Stats::Public
  class SolicitationsInRegionsStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.all
    end

    def territories
      Territory.where(region: true, code_region: YAML.safe_load(ENV['DEPLOYED_REGIONS_CODES']))
    end

    def in_regions(query)
      query
        .by_territories(territories)
        .group_by_month(date_group_attribute)
        .count
    end

    def out_of_regions(query)
      query
        .where.not(id: Solicitation.by_territories(territories))
        .group_by_month(date_group_attribute)
        .count
    end

    def filtered(query)
      if institution.present?
        query.merge! institution.received_solicitations
      end
      if @start_date.present?
        query = query.where("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @in_regions ||= in_regions(query).values
      @out_of_regions ||= out_of_regions(query).values

      as_series(@in_regions, @out_of_regions)
    end

    def count
      build_series
      percentage_two_numbers(@in_regions, @out_of_regions)
    end

    def subtitle
      I18n.t('stats.series.solicitations_in_regions.subtitle_html')
    end

    private

    def as_series(in_regions, out_of_regions)
      [
        {
          name: I18n.t('stats.out_of_regions'),
            data: out_of_regions
        },
        {
          name: I18n.t('stats.in_regions'),
            data: in_regions
        }
      ]
    end
  end
end
