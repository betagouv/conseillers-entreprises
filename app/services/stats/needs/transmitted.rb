module Stats::Needs
  # Besoins mis en relation
  class Transmitted
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Need.diagnosis_completed.where(created_at: @start_date..@end_date)
      # Ajoute un joins ici pour les jointures du '.size' ne fonctionne pas sans en production uniquement
      # Need.diagnosis_completed.joins(matches: :expert).where(created_at: @start_date..@end_date)
    end

    def build_series
      query = main_query
      query = Stats::Filters::Needs.new(query).call

      @needs = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @needs.push(month_query.count)
      end

      as_series(@needs)
    end

    def chart
      'line-chart'
    end

    def count
      Stats::Filters::Needs.new(query).call.size
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
