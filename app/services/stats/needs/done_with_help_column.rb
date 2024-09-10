# Stats montrant l'evolution du nombre de demandes donnant lieu à échange avec un conseiller
module Stats::Needs
  class DoneWithHelpColumn
    include ::Stats::BaseStats

    def initialize(params)
      @start_date = Time.zone.now.beginning_of_month - 11.months
      @end_date = Time.zone.now.end_of_day
    end

    def main_query
      Need.diagnosis_completed
        .joins(:diagnosis).merge(Diagnosis.from_solicitation)
        .where(status: :done)
    end

    # Stat principale, on ne filtre pas
    def filtered(query)
      query
    end

    def count
      main_query.count
    end

    def category_group_attribute
      Arel.sql('true')
    end

    def category_order_attribute
      Arel.sql('true')
    end

    def category_name(_)
      I18n.t('stats.series.done_with_help_column.series')
    end

    def chart
      'stats-chart'
    end

    def format
      'Total : <b>{point.stackTotal}</b>'
    end

    def colors
      %w[#000091]
    end
  end
end
